# WD

## Spindown

Some WD drives are set to poweroff after 6 seconds, specifically exterenal drives

If these drives are extracted, some adjustments may need to be made to ensure the drive doesn't wear itself to death

The drive status can be checked by running:

`# smartctl -a /dev/sdX`

Check the stats for `Load_Cycle_Count`

This feature can be disabled by running:

`# hdparm -J 30 --please-destroy-my-drive /dev/sdX`

Then ensuring the drive is fully powered off and on

## ERC

https://abatis.org.uk/projects/erc/

Some WD drives do not have ERC enabled but it is supported

ERC can be checked by running:

`# smartctl -a /dev/sdX`

Check for: `SCT Error Recovery Control supported`


It can be enabled by running:

`# smartctl -l scterc,70,70 /dev/sdX`
