#!/bin/bash
# Authored by Antoine CICHOWICZ | Github: Yris Ops
# Copyright: Apache License 2.0

# Function to fetch instance metadata
fetch_instance_metadata() {
  local endpoint="$1"
  curl -s "http://169.254.169.254/latest/meta-data/${endpoint}" 2>/dev/null
}

# Fetch the ID of the environment host Amazon EC2 instance and region.
INSTANCEID=$(fetch_instance_metadata "instance-id")
REGION=$(fetch_instance_metadata "placement/availability-zone" | sed 's/\(.*\)[a-z]/\1/')

echo "EBS Volume Resizer $REGION/$INSTANCEID"

# Fetch the EBS volumes attached to the instance.
fetch_attached_volumes() {
  aws ec2 describe-instances \
    --instance-id "$INSTANCEID" \
    --query "Reservations[0].Instances[0].BlockDeviceMappings[*].Ebs.VolumeId" \
    --output text \
    --region "$REGION"
}

# Prompt for the volume to use.
prompt_for_volume_selection() {
  echo "EBS Volumes:"
  PS3='Please select the EBS volume to resize (e.g., 1): '
  select VOLUME_ID in $VOLUMES; do 
    break
  done
}

# Verify if the provided size is valid and greater than the current volume size.
verify_size_input() {
  if [[ -n ${SIZE//[0-9]/} ]] || [ "$SIZE" -lt "$VOLUME_SIZE" ]; then
    echo "Invalid input. Ensure size is a numerical value greater than or equal to $VOLUME_SIZE GiB."
    exit 1
  fi
}

# Function to resize the EBS volume.
resize_volume() {
  echo "Resizing volume $VOLUME_ID to $SIZE GiB..."
  local RESULT=$(aws ec2 modify-volume --volume-id "$VOLUME_ID" --size "$SIZE" 2>&1)
  if [ $? -ne 0 ]; then
    echo "Failed to modify the volume. Error: $RESULT"
    exit 1
  fi
}

# Function to check resize completion status.
check_resize_status() {
  while [ "$(aws ec2 describe-volumes-modifications \
            --volume-id "$VOLUME_ID" \
            --filters Name=modification-state,Values="optimizing","completed" \
            --query "length(VolumesModifications)" \
            --output text)" != "1" ]; do
    sleep 1
  done
}

# Function to expand the file system after volume resize.
expand_filesystem() {
  local DEVICE="$1"
  local PARTITION="$2"

  sudo growpart "$DEVICE" 1

  local OS_RELEASE=$(cat /etc/os-release)
  if [[ "$OS_RELEASE" == *"VERSION_ID=\"2\""* ]]; then
    sudo xfs_growfs -d /
  else
    sudo resize2fs "$PARTITION"
  fi
}

VOLUMES=$(fetch_attached_volumes)
prompt_for_volume_selection

VOLUME_SIZE=$(aws ec2 describe-volumes --volume-ids "$VOLUME_ID" --query "Volumes[0].Size" --output text)
read -p "Enter new EBS Storage in GiB (must be greater than $VOLUME_SIZE) for '$VOLUME_ID': " SIZE
verify_size_input

read -p "Resizing EBS Storage to $SIZE GiB, continue? (Y/N): " confirm
if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
  echo "Exiting..."
  exit 1
fi

resize_volume
check_resize_status

# Determine the filesystem and expand accordingly.
if [[ -e "/dev/xvda" && $(readlink -f /dev/xvda) = "/dev/xvda" ]]; then
  expand_filesystem "/dev/xvda" "/dev/xvda1"
else
  expand_filesystem "/dev/nvme0n1" "/dev/nvme0n1p1"
fi
