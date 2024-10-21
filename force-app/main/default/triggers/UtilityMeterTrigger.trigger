/**
 * Created by mike on 5/10/22.
 */

trigger UtilityMeterTrigger on UtilityMeter__c (after insert, after update) {
    Domain.triggerHandler(UtilityMeterDomain.class);
}