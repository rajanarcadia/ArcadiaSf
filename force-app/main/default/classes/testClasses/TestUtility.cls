@isTest
@namespaceAccessible
public class TestUtility {
    //Test utility constants
    public static final String PROFILE_ADMIN = 'System Administrator';
    public static final String PROFILE_STANDARD_USER = 'Standard Platform User';
    public static final String PERMSET_LOG = 'UrjanetLog';
    public static final String ASYNC_JOB_PROCESSING = 'UrjanetAsyncJobProcessing';
    public static final String PERMSET_CREATE_CREDENTIAL = 'UrjanetCreateUtilityCredentials';
    public static final String PERMSET_SUSTAINABLE_MANAGER_READ = 'UrjanetSustainabilityManagerRead';
    public static final String NET_ZERO_CLOUD_MANAGER = 'NetZeroManager';
    public static final String NET_ZERO_CLOUD_AUDITOR = 'NetZeroAuditor';
    @namespaceAccessible
    public static final String METER_ID = '1ecc28b8-1edc-da68-a63e-02ebc121089d';

    @namespaceAccessible
    public static final String CREDENTIAL_ID = '1234456-1abc-d234-a63e-02ebc121089d';

    public static final String SITE_ID = '2344445-1edf-d457-a7be-02ebc121089d';
    public static Integer idNum = 1;
    public static UtilityCredential__c setupUtilityCredential(String name, String correlationId, Boolean doInsert) {
        UtilityCredential__c credential = new UtilityCredential__c();

        credential.Name = name;

        credential.CorrelationId__c = correlationId;

        if (doInsert) {
            insert credential;
        }

        return credential;
    }

    /****************************************
        USERS UTILITIES
    *****************************************/

    public enum UserType {
        SUSTAINABLE_MANAGER,
        LOG_ACCESS,
        CREATE_CREDENTIALS,
        NET_ZERO_CLOUD_MANAGER,
        NET_ZERO_CLOUD_AUDITOR,
        ASYNC_JOB_PROCESSING
    }
    public static Map<UserType, String> permSetNameByUserTypeMap = new Map<UserType, String>{
        UserType.SUSTAINABLE_MANAGER => PERMSET_SUSTAINABLE_MANAGER_READ,
        UserType.LOG_ACCESS => PERMSET_LOG,
        UserType.CREATE_CREDENTIALS => PERMSET_CREATE_CREDENTIAL,
        UserType.NET_ZERO_CLOUD_MANAGER => NET_ZERO_CLOUD_MANAGER,
        UserType.NET_ZERO_CLOUD_AUDITOR => NET_ZERO_CLOUD_AUDITOR,
        UserType.ASYNC_JOB_PROCESSING => ASYNC_JOB_PROCESSING
    };
    private static Map<UserType, Id> permSetIdByUserTypeMap;

    public static string getRandomEmail() {
        Integer i = (integer) (Math.random() * 1000);
        return 'test-' + i.format() + '@test.com';
    }
    public static String getRandomPhoneNumber() {
        return String.valueOf(Math.round((Math.random() * (900000) + 1000000000)));
    }

    /**
     * loads permission sets into the static map by usertype
     * @return   none
     */
    public static void loadPermSets() {
        // load permset ids by usertype if not already loaded
        if (permSetIdByUserTypeMap == null) {
            Set<String> permSetNameSet = new Set<String>();
            permSetNameSet.addAll(permSetNameByUserTypeMap.values());
            Map<String, Id> permSetIdByNameMap = getPermissionSets(permSetNameSet);

            permSetIdByUserTypeMap = new Map<UserType, Id>();
            for (UserType uType : UserType.values()) {
                String permSetName = permSetNameByUserTypeMap.get(uType);
                Id permSetId = permSetIdByNameMap.get(permSetName);

                if (permSetId != null) {
                    permSetIdByUserTypeMap.put(uType, permSetId);
                }
            }
        }
    }

    /**
     * Get Permission Sets
     *
     * @param permissionSetNames
     *
     * @return Map of PermissionSet.Name to PermissionSet.Id
     **/
    public static Map<String, Id> getPermissionSets(Set<String> permissionSetNames) {
        List<PermissionSet> pss = [SELECT Id, Name FROM PermissionSet WHERE Name IN :permissionSetNames];
        Map<String, Id> psMap = new Map<String, Id>();

        for (PermissionSet ps : pss) {
            psMap.put(ps.Name, ps.Id);
        }

        return psMap;
    }

    /**
     * Create Admin User with admin permission set
     * @param usrType
     * @return         User
     */
    public static User createUserWithAdminProfile(Set<UserType> usrTypes, String email) {
        loadPermSets();

        // create the user
        User usr = setupUserWithProfile(PROFILE_ADMIN, email, false);
        insert usr;
        PermissionSetLicense plNZC = [SELECT Id FROM PermissionSetLicense WHERE Masterlabel = 'Net Zero Cloud'];
        insert new PermissionSetLicenseAssign(AssigneeId = usr.id, PermissionSetLicenseId = plNZC.id);

        addPermissionSetsForUser(usr.Id, usrTypes, true);

        return usr;
    }

    /**
     * Create Standard User with Permission Set for UserType
     * @param  usrType the type of user to be created (permset)
     * @param  email   supplied email
     * @return         User
     */
    public static User createUserWithStandardProfile(UserType usrType, String email) {
        loadPermSets();

        // create the user
        User usr = setupUserWithProfile(PROFILE_STANDARD_USER, email, true);
        addPermissionSetsForUser(usr.Id, new Set<UserType>{ usrType }, true);

        return usr;
    }

    /**
     * Setup User with Profile
     **/
    /**
     * override to handle old test classes (temporary)
     * @param profileName profileName description
     * @param  email     email description
     * @param  doInsert  doInsert description
     * @return - Constructed User record
     */
    public static User setupUserWithProfile(String profileName, String email, Boolean doInsert) {
        return setupUser(profileName, email, doInsert);
    }

    /**
     * setupUser description
     * @param  profileName
     * @param  email
     * @param  doInsert
     * @return - Constructed User record
     */
    public static User setupUser(String profileName, String email, Boolean doInsert) {
        return setupUser(profileName, 'Test', 'User ', email, doInsert);
    }

    /**
     * Setup User with Profile, name and number
     * @param profileName
     * @param firstName
     * @param lastName
     * @param email
     * @param doInsert
     * @return - Constructed User record
     */
    public static User setupUser(
        String profileName,
        String firstName,
        String lastName,
        String email,
        Boolean doInsert
    ) {
        if (email == null) {
            email = 'unit.test.user@' + UserInfo.getOrganizationId() + '.apexanalytixtest.com';
        }
        User u = new User();
        u.FirstName = firstName;
        u.LastName = lastName;
        u.Email = email;
        u.Username = email;
        u.Alias = 'tuser' + String.valueOf(Integer.valueOf((Math.random() * 999)));
        u.Phone = '503-555-1212';
        u.ProfileId = getIdForProfile(profileName);
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';

        if (UserInfo.isMultiCurrencyOrganization()) {
            ((SObject) u).put('CurrencyIsoCode', 'USD');
        }

        if (doInsert) {
            insert u;
        }

        return u;
    }

    /**
     * Add Permission Set
     *
     * @param userId
     * @param permissionSetId
     * @param doInsert
     *
     * @return fully formed PermissionSetAssignment record
     **/
    public static List<PermissionSetAssignment> addPermissionSet(
        Id userId,
        List<Id> permissionSetIds,
        Boolean doInsert
    ) {
        List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
        for (Id permsetId : permissionSetIds) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = userId;
            psa.PermissionSetId = permsetId;
            psas.add(psa);
        }

        if (doInsert) {
            insert psas;
        }
        return psas;
    }

    /**
     * Add Permission Sets for User
     *
     * @param userId
     * @param usrType
     * @param doInsert
     *
     * @return fully formed List of PermissionSetAssignment records
     **/
    public static List<PermissionSetAssignment> addPermissionSetsForUser(
        Id userId,
        Set<UserType> usrTypes,
        Boolean doInsert
    ) {
        List<Id> permSetIds = new List<Id>();
        for (TestUtility.UserType usrType : usrTypes) {
            permSetIds.add(permSetIdByUserTypeMap.get(usrType));
        }

        // Query for and get unpackaged perm set
        PermissionSet unpackagedPerm = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Urjanet_Unpackaged' LIMIT 1];
        if (unpackagedPerm != null && unpackagedPerm.Id != null) {
            permSetIds.add(unpackagedPerm.Id);
        }

        List<PermissionSetAssignment> permissionSets = new List<PermissionSetAssignment>();
        permissionSets.addAll(addPermissionSet(userId, permSetIds, false));

        if (doInsert) {
            insert permissionSets;
        }

        return permissionSets;
    }

    /**
     * Get Id For Profile
     *
     * @param profileName
     * @return Profile Id
     **/
    private static Map<String, Id> mapProfileNameToId = new Map<String, Id>();
    private static Id getIdForProfile(String profileName) {
        if (!mapProfileNameToId.containsKey(profileName.toUpperCase())) {
            for (Profile p : [SELECT Id, Name FROM Profile WHERE Name = :profileName]) {
                mapProfileNameToId.put(p.Name.toUpperCase(), p.Id);
            }
        }

        return mapProfileNameToId.get(profileName.toUpperCase());
    }

    /**
     * creates an admin user with admin perm set with specified email
     * @param  email email description
     * @return       user
     */
    @namespaceAccessible
    public static User createUserAdmin(String email) {
        return createUserWithAdminProfile(
            new Set<UserType>{
                UserType.SUSTAINABLE_MANAGER,
                UserType.CREATE_CREDENTIALS,
                UserType.LOG_ACCESS,
                UserType.NET_ZERO_CLOUD_AUDITOR,
                UserType.NET_ZERO_CLOUD_MANAGER,
                UserType.ASYNC_JOB_PROCESSING
            },
            email
        );
    }

    /**
     * creates Random Id for testing purposes
     * @param  SObjectType sot
     * @return       String
     */
    public static String getRandomId(SObjectType sot) {
        String idResult = String.valueOf(idNum++);
        return sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - idResult.length()) + idResult;
    }

    public class GenericStub implements System.StubProvider {
        public Map<String, Integer> methodCallCount { get; set; }
        public Map<String, Object> methodNameToReturnObject { get; set; }

        public GenericStub(Map<String, Object> methodNameToReturnObject) {
            this.methodCallCount = new Map<String, Integer>();
            this.methodNameToReturnObject = methodNameToReturnObject;
        }

        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (this.methodCallCount.containsKey(stubbedMethodName)) {
                this.methodCallCount.put(stubbedMethodName, this.methodCallCount.get(stubbedMethodName) + 1);
            } else {
                this.methodCallCount.put(stubbedMethodName, 1);
            }

            if (this.methodNameToReturnObject.containsKey(stubbedMethodName)) {
                Object toReturn = this.methodNameToReturnObject.get(stubbedMethodName);
                if (toReturn instanceof Exception) {
                    throw (Exception) toReturn;
                } else {
                    return toReturn;
                }
            } else {
                return null;
            }
        }
    }
    @namespaceAccessible
    public static void insertDuplicateMeterUsage(
        String parentMeterId,
        String usageName,
        Decimal measuredUsage,
        Date periodStart,
        Date periodEnd,
        String deregulationStatus,
        String accountType
    ) {
        System.runAs(TestUtility.createUserAdmin('arcadiaAdmin2@test.com')) {
            if (String.isBlank(parentMeterId) || parentMeterId == null) {
                return;
            }

            UtilityMeterUsage__c initialUsage = new UtilityMeterUsage__c(
                UrjanetId__c = '1ee97dee-de1d-dc77-be86-5a0222741fd9',
                Name = usageName,
                UtilityMeter__c = parentMeterId,
                DeregulationStatus__c = deregulationStatus,
                AccountType__c = accountType,
                MeasuredUsage__c = measuredUsage,
                PeriodStart__c = periodStart,
                PeriodEnd__c = periodEnd
            );
            UtilityMeterUsage__c dupUsage = new UtilityMeterUsage__c(
                UrjanetId__c = '1234',
                Name = usageName,
                UtilityMeter__c = parentMeterId,
                DeregulationStatus__c = deregulationStatus,
                AccountType__c = accountType,
                MeasuredUsage__c = measuredUsage,
                PeriodStart__c = periodStart,
                PeriodEnd__c = periodEnd
            );
            insert initialUsage;
            insert dupUsage;
        }
    }

    public static StaticResourceCalloutMock getStaticResourceCalloutMock(
        String staticResourceName,
        Integer statusCode
    ) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(staticResourceName);
        mock.setStatusCode(statusCode);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }
    public static void insertLastSyncDetails() {
        LastSuccessfulSyncDate__c lastSyncDetails = new LastSuccessfulSyncDate__c(
            LastSyncDate__c = DateTime.now(),
            PreviousLastSyncDate__c = Datetime.newInstance(1990, 1, 1)
        );
        insert lastSyncDetails;
    }
    
    @namespaceAccessible
    public static List<UtilityMeter__c> createUtilityMeters(Id siteId, String meterName, Integer startIndex, Integer lastIndex, Boolean enabled, Boolean samePodNumber, String serviceType) {
        List<UtilityMeter__c> meters = new List<UtilityMeter__c>();
        for(Integer i = startIndex; i < lastIndex; i++) {
            meters.add(new UtilityMeter__c(
                Name = meterName,
                UrjanetId__c = 'Test Urjanet Id ' + i,
                PodNumber__c = samePodNumber ? 'Test Pod Number' : 'Test Pod Number ' + i,
                Enabled__c = enabled,
                StationaryAssetEnvironmentalSource__c = siteId,
                ServiceType__c = serviceType
            ));
        }
        insert meters;
        return meters;
    }

    @namespaceAccessible
    public static List<UtilityMeterUsage__c> createUtilityMeterUsages(List<UtilityMeter__c> meters, Integer startIndex, Integer lastIndex, Boolean sameStatementId, Decimal measuredUsage, Boolean toBeIgnored, String deregulationStatus) {
        List<UtilityMeterUsage__c> usages = new List<UtilityMeterUsage__c>();
    
        if (meters.isEmpty()) {
            return usages;
        }
    
        for (UtilityMeter__c meter : meters) {
            if (meter.Id == null) {
                continue;
            }
            String usageUnit;
            if(meter.ServiceType__c == 'water'){
                usageUnit = 'ccf';
            }
            else {
                usageUnit = 'kWh';
            }
            for (Integer i = startIndex; i < lastIndex; i++) {
                String uniqueUrjanetId = generateUniqueId();

                usages.add(new UtilityMeterUsage__c(
                    UrjanetId__c = uniqueUrjanetId,
                    UtilityMeter__c = meter.Id,
                    MeasuredUsage__c = measuredUsage,
                    PeriodStart__c = Date.today(),
                    PeriodEnd__c = Date.today() + 30,
                    Arcadia_Statement_ID__c = sameStatementId ? 'Test Statement ID' : 'Test Statement ID ' + i,
                    To_Be_Ignored__c = toBeIgnored,
                    DeregulationStatus__c = deregulationStatus,
                    UsageUnit__c = usageUnit
                ));
            }
        }
        try {
            insert usages;
        } catch (DmlException e) {
            Logger.getInstance()
                .log(
                    TestUtility.class.getName(),
                    e
                );
        }
        return usages;
    }
    private static String generateUniqueId() {
        return String.valueOf(Crypto.getRandomLong()) + String.valueOf(Crypto.getRandomLong());
    }
}