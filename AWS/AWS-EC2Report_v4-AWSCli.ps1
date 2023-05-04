$EC2InstancesCLI = aws ec2 describe-instances --profile AWS-QBC --region us-east-1 --output json
$EC2InstancesJSON = $EC2InstancesCLI | ConvertFrom-Json

$EC2Helper = $EC2InstancesJSON.Reservations.Instances

$EC2 = @()

foreach ($Item in $EC2Helper) {

    # Get Item Tag = NAME

    $Flag = 0
    $TagIndex = 0
    $Tags = $Item.Tags
    
    foreach ($Tag in $Tags){

        $Flag ++
        IF ($Tag.Key -eq "Customer Number") {$TagCNumber = $Flag -1}
        IF ($Tag.Key -eq "Customer Name") {$TagCName = $Flag -1}
        IF ($Tag.Key -eq "Name") {$TagName = $Flag -1}

    }

    $Hash = [ordered]@{
        InstanceId            = $Item.InstanceId
        KeyName               = $Item.KeyName.ToUpper()
        Name                  = ($Item.Tags.Value.GetValue($TagName)).ToUpper()
        InstanceType          = $Item.InstanceType
        PrivateIpAddress      = $Item.PrivateIpAddress
        PublicIpAddress       = $Item.PublicIpAddress
        State                 = $Item.State.Name.ToUpper()
        StateTransitionReason = $Item.StateTransitionReason
        BlockDeviceMappings   = $Item.BlockDeviceMappings.DeviceName
        RoodDeviceName        = $Item.RootDeviceName
        RootDeviceType        = $Item.RootDeviceType.ToUpper()
        SecurityGroups        = $Item.SecurityGroups.GroupName
        CustomerNumber        = ($Item.Tags.Value.GetValue($TagCNumber)).ToUpper()
        CustomerName          = ($Item.Tags.Value.GetValue($TagCName)).ToUpper()

    }

    $NewOBJ = New-Object psobject -Property $Hash
    $EC2 += $NewOBJ 

}

$EC2 | Out-GridView