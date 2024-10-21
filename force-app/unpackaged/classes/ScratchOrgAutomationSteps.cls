public with sharing class ScratchOrgAutomationSteps {
    private static final String ORG_ID = System.Label.Organization_ID;

    public static void Step1_UserPermission_Assignment() {
        List<PermissionSet> permissionSetList = [SELECT Id, Name FROM PermissionSet WHERE Name LIKE '%Urjanet%'];
        List<User> userList = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator'];
        List<PermissionSetAssignment> existingPermissionSetAssingments = [
            SELECT Id, PermissionSetId, AssigneeId
            FROM PermissionSetAssignment
            WHERE PermissionSetId IN :permissionSetList AND AssigneeId IN :userList
        ];
        Map<Id, Set<Id>> permissionSetIdToUsersIdMap = new Map<Id, Set<Id>>();
        for (PermissionSetAssignment psAssingement : existingPermissionSetAssingments) {
            if (!permissionSetIdToUsersIdMap.containsKey(psAssingement.PermissionSetId)) {
                permissionSetIdToUsersIdMap.put(psAssingement.PermissionSetId, new Set<Id>{ psAssingement.AssigneeId });
            } else {
                permissionSetIdToUsersIdMap.get(psAssingement.PermissionSetId).add(psAssingement.AssigneeId);
            }
        }
        List<PermissionSetAssignment> permissionAssignmenets = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permissionSetList) {
            for (User userRec : userList) {
                if (
                    !permissionSetIdToUsersIdMap.containsKey(ps.Id) ||
                    (permissionSetIdToUsersIdMap.containsKey(ps.Id) &&
                    !permissionSetIdToUsersIdMap.get(ps.Id).contains(userRec.Id))
                ) {
                    PermissionSetAssignment psa = new PermissionSetAssignment(
                        PermissionSetId = ps.Id,
                        AssigneeId = userRec.Id
                    );
                    permissionAssignmenets.add(psa);
                }
            }
        }
        if (permissionAssignmenets != null && !permissionAssignmenets.isEmpty()) {
            try {
                insert permissionAssignmenets;
                System.debug('Permissions are assigned to the Admin Users');
            } catch (Exception e) {
                System.debug('Error in Permission Set assignment Step : ' + e.getMessage());
            }
        } else if (permissionSetList != null && !permissionSetList.isEmpty() && permissionAssignmenets.isEmpty()) {
            System.debug('Permissions are already assigned to the Admin Users');
        }
    }

    public static void Step5_UpdateCustomSettingsData() {
        List<UrjanetSettings__c> urjanetSettings = [SELECT Id FROM UrjanetSettings__c LIMIT 1];
        UrjanetSettings__c urjanetSetting = prepareArcadiaCustomSettingRecord(urjanetSettings);
        try {
            if (urjanetSetting.Id != null) {
                update urjanetSetting;
            } else {
                insert urjanetSetting;
            }
            System.debug('Arcadia Custom Setting has been updated with the Organization Id :' + ORG_ID);
        } catch (Exception e) {
            System.debug('Error in updating the Arcadia Custom Setting with the Organization Id ' + e.getMessage());
        }
    }

    public static void Step9_CreateTestAccountSupplierEFrecords() {
        try {
            Account acc = new Account(Name = 'Test Account');
            insert acc;

            Supplier supplierRec = new Supplier(AccountId = acc.Id, Name = 'Test Supplier');
            insert supplierRec;

            ElectricityEmssnFctrSet ef = new ElectricityEmssnFctrSet(
                Name = 'Electricity EF ' + DateTime.Now(),
                LocationBasedBiomassMixPct = 50,
                LocationBasedCoalMixPct = 50,
                MarketBasedBiomassMixPct = 50,
                MarketBasedCoalMixPct = 50
            );
            insert ef;

            OtherEmssnFctrSet oef = new OtherEmssnFctrSet(Name = 'Other EF ' + DateTime.Now());
            insert oef;

            OtherEmssnFctrSetItem oefItem = new OtherEmssnFctrSetItem(
                ParentEmissionFactorId = oef.Id,
                FuelType = 'NaturalGas',
                CalorificValue = 100
            );
            insert oefItem;

            StnryAssetEnvrSrc site = new StnryAssetEnvrSrc(
                Name = 'Test Site ' + DateTime.Now(),
                ElectricityEmssnFctrId = ef.id,
                OtherEmssnFctrId = oef.Id
            );
            insert site;
            System.debug(
                'Test records for Supplier , Site with Emission Factor and other Emission Factor are created successfully'
            );
        } catch (Exception e) {
            System.debug(
                'Test records for Supplier , Site with Emission Factor and other Emission Factor creation failed : ' +
                e.getMessage()
            );
        }
    }

    public static UrjanetSettings__c prepareArcadiaCustomSettingRecord(List<UrjanetSettings__c> urjanetSettings) {
        UrjanetSettings__c urjanetSetting = new UrjanetSettings__c();
        if (urjanetSettings != null && !urjanetSettings.isEmpty()) {
            urjanetSetting.Id = urjanetSettings[0].Id;
        }
        urjanetSetting.SetupOwnerId = UserInfo.getOrganizationId();
        urjanetSetting.DevelopmentOrg__c = true;
        urjanetSetting.OrganizationId__c = ORG_ID;
        return urjanetSetting;
    }
}