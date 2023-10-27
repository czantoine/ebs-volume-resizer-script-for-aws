# EBS Volume Resizer Script for AWS

<p align="center">
	<a href="https://join.slack.com/t/yrisgroupe/shared_invite/zt-1q51z8dmv-GC0XzUSclzBnUQ0tpKhznw"><img alt="Slack Shield" src="https://img.shields.io/badge/slack-yris-brightgreen.svg?logo=slack"></a>
	<a href="https://github.com/Yris-ops/ebs-volume-resizer-script-for-aws"><img alt="Repo size" src="https://img.shields.io/github/repo-size/Yris-ops/ebs-volume-resizer-script-for-aws"></a>
	<a href="https://github.com/Yris-ops/ebs-volume-resizer-script-for-aws"><img alt="Stars" src="https://img.shields.io/github/stars/Yris-ops/ebs-volume-resizer-script-for-aws"></a>
	<a href="https://twitter.com/cz_antoine"><img alt="Twitter" src="https://img.shields.io/twitter/follow/cz_antoine?style=social"></a>
	<a href="https://www.linkedin.com/in/antoine-cichowicz-837575b1"><img alt="Linkedin" src="https://img.shields.io/badge/-Antoine-blue?style=flat-square&logo=Linkedin&logoColor=white"></a>
<p>

Automate the hassle of resizing EBS volumes on AWS Cloud9.

![EBS Volume Resizer Script for AWS](./img/ebs-volume-resizer-script-for-aws.gif)

**Disclaimer:** Please note that once an EBS volume has been increased in size, it cannot be reduced again. Test with caution.

## Features

- Fetch Instance Metadata.
- Identify the running Instance and its Region.
- Fetch all attached EBS Volumes.
- Interactive prompt for EBS volume selection.
- Input verification for the new size.
- Resizing of selected EBS volume.
- Confirmation checks before actual resizing.
- Resize status check.
- File system expansion post volume resize.
- Disk format handling (supports xfs and ext4).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This repository is licensed under the Apache License 2.0. See the LICENSE file.