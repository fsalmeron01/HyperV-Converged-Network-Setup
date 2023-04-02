# Converged Network Setup Script for Hyper-V

This PowerShell script sets up a converged network in Hyper-V with Management, LiveMigration, iSCSI, and VM traffic. It performs the following actions:

- Creates a Converged Team with the specified physical NICs.
- Creates a vSwitch on top of the Converged Team.
- Creates vNICs for Management, LiveMigration, iSCSI, and VM traffic.
- Configures QoS policies for vNICs.
- Configures IP settings for vNICs.
- Connects iSCSI vNIC to iSCSI target.

## Usage

To use the script, follow these steps:

1. Open PowerShell as an administrator.
2. Navigate to the directory where the script is saved.
3. Run the script using the following command:

   ```powershell
   .\converged-network-setup.ps1 -PhysicalNICs "NIC1", "NIC2", "NIC3", "NIC4", "NIC5", "NIC6", "NIC7", "NIC8"
