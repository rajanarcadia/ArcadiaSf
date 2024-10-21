public with sharing class SupplierSelector extends Selector{
    public SupplierSelector() {
        super(Schema.Supplier.SObjectType);
    }

    public SupplierSelector(Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr) {
        super(Schema.Supplier.SObjectType, enforceCRUD, enforceFLS, EnforceShr);
    }

    public override Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'Name'
        };
    }

    public List<Supplier> getSuppliersByIds(Set<String> setSupplierIds) {
        List<String> queryFields = new List<String>(this.getDefaultFields());

        Map<String, Object> queryArgs = new Map<String, Object>{ 'setSupplierIds' => setSupplierIds };

        String query =
            'SELECT ' +
            String.join(queryFields, ', ') +
            ' FROM Supplier' +
            ' WHERE Id IN :setSupplierIds';

        return new List<Supplier>(
            (List<Supplier>) Data.read(
                query,
                queryArgs,
                this.isEnforcingCRUD(),
                this.isEnforcingFLS(),
                this.isEnforcingShr()
            )
        );
    }
}