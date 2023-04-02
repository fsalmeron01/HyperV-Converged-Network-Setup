<#
Name: ConvergedNetwork.ps1
Description: This PowerShell script sets up a converged network in Hyper-V with Management, LiveMigration, iSCSI, and VM traffic.
Author: Francisco Salmeron
Created: 04/01/2023
Modified: 04/01/2023
Version: 1.0
#>

<#
.SYNOPSIS
    This script sets up a converged network in Hyper-V with Management, LiveMigration, iSCSI, and VM traffic.

.DESCRIPTION
    This script performs the following actions:
    - Creates a Converged Team with the specified physical NICs.
    - Creates a vSwitch on top of the Converged Team.
    - Creates vNICs for Management, LiveMigration, iSCSI, and VM traffic.
    - Configures QoS policies for vNICs.
    - Configures IP settings for vNICs.
    - Connects iSCSI vNIC to iSCSI target.
#>

function New-ConvergedNetwork {
    param (
        [string[]]$PhysicalNICs
    )

    # Create a Converged Team
    New-NetLbfoTeam -Name "ConvergedTeam" -TeamMembers $PhysicalNICs -TeamingMode SwitchIndependent -LoadBalancingAlgorithm HyperVPort

    # Create a vSwitch
    New-VMSwitch -Name "ConvergedvSwitch" -NetAdapterName "ConvergedTeam" -AllowManagementOS $false -MinimumBandwidthMode Weight

    # Create vNICs
    Add-VMNetworkAdapter -ManagementOS -Name "Mgmt" -SwitchName "ConvergedvSwitch"
    Add-VMNetworkAdapter -ManagementOS -Name "LiveMigration" -SwitchName "ConvergedvSwitch"
    Add-VMNetworkAdapter -ManagementOS -Name "iSCSI" -SwitchName "ConvergedvSwitch"
    Add-VMNetworkAdapter -ManagementOS -Name "VM" -SwitchName "ConvergedvSwitch"

    # Configure QoS policies for vNICs
    New-NetQosPolicy -Name "Management" -NetAdapterName "vEthernet (Mgmt)" -MinBandwidthWeight 10
    New-NetQosPolicy -Name "LiveMigration" -NetAdapterName "vEthernet (LiveMigration)" -MinBandwidthWeight 20
    New-NetQosPolicy -Name "iSCSI" -NetAdapterName "vEthernet (iSCSI)" -MinBandwidthWeight 10
    New-NetQosPolicy -Name "VM" -NetAdapterName "vEthernet (VM)" -MinBandwidthWeight 40

    # Configure IP settings for vNICs
    New-NetIPAddress -InterfaceAlias "vEthernet (Mgmt)" -IPAddress 10.10.20.2 -PrefixLength 24 -DefaultGateway 10.10.20.1
    Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Mgmt)" -ServerAddresses 10.10.10.1
    New-NetIPAddress -InterfaceAlias "vEthernet (LiveMigration)" -IPAddress 10.10.30.2 -PrefixLength 24
    Set-DnsClientServerAddress -InterfaceAlias "vEthernet (LiveMigration)" -ServerAddresses 10.10.10.1
    New-NetIPAddress -InterfaceAlias "vEthernet (iSCSI)" -IPAddress 10.10.70.3 -PrefixLength 24
    Set-DnsClientServerAddress -InterfaceAlias "vEthernet (iSCSI)" -ServerAddresses 10.10.10.1

    # Connect iSCSI vNIC to iSCSI Target
    $targetIP = "10.10.70.2" # Replace with your iSCSI target IP
    iscsicli QAddTargetPortal $targetIP
    $targetName = (iscsicli ListTargets | Where-Object { $_ -match "iqn" }).Trim() # Replace 'iqn' with your target's IQN if needed
    iscsicli QLoginTarget $targetName
}

# Main entry point
$PhysicalNICs = "NIC1", "NIC2", "NIC3", "NIC4", "NIC5", "NIC6", "NIC7", "NIC8"
New-ConvergedNetwork -PhysicalNICs $PhysicalNICs

