/*******************************************************************************
Created By         :   Baswaraj Patil
Created Date       :   23-OCT-2018
Usage              :   The usage of this batch class is to fetch all commission records to rollup the achieved quota to AE's/Owner's Manager's
Quota Product as a Manager's achievement against applied quota products. 
********************************************************************************/
global class Commissions_ManagersQualifierBatch_New implements Database.Batchable<sObject>, Database.Stateful{
    string managersTeam = CommissionTeams__c.getInstance('MANAGERS_TEAM').Team_Name__c;
    Integer monthValue = system.today().Month();
    String brokerRDteam = 'Q2' ;   
    
    map<Id,Quota__c> mapManagersQuotasWithQP;
    map<string,string> mapMgrNameWRTQuotaId = new map<string,string>();
    set<Id> setQuotaProdIds = new set<Id>();
    set<string> setQuotaProdFamilyNames = new set<string>();
    map<Id, Quota_Product__c> mapQPCalculateUpdate = new map<Id, Quota_Product__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        If (monthValue <= 3) {       
            brokerRDteam = 'Q3';
        } else if (monthValue <= 6) {
            brokerRDteam = 'Q4';
        } else if (monthValue <= 9) {
            brokerRDteam = 'Q1';
        }
        mapManagersQuotasWithQP = new map<Id,Quota__c>([SELECT Id, Owner_Name__c, Period_Name__c, User__c,
                                                        (SELECT Id, Product_Name__c, Product_Name1__c, Product_Family__c, Sales_Achivement__c
                                                         FROM Quota_Products__r)
                                                        FROM Quota__c
                                                        WHERE User_Team__c = :managersTeam 
                                                        AND (Quota_StartDate__c = THIS_MONTH 
                                                             OR (Quota_StartDate__c = THIS_YEAR AND Current_Quater__c =:brokerRDteam))
                                                       ]);
        if(mapManagersQuotasWithQP != null && mapManagersQuotasWithQP.size() > 0){ 
            for(Quota__c mq : mapManagersQuotasWithQP.values()){
                if(mq.Quota_Products__r.size() > 0){
                    mapMgrNameWRTQuotaId.put(mq.Owner_Name__c, mq.Id);
                    for(Quota_Product__c qp : mq.Quota_Products__r){
                        if(qp.Product_Name__c != null){
                            setQuotaProdIds.add(qp.Product_Name__c);
                        }
                        else if(String.isNotBlank(qp.Product_Family__c)){
                            setQuotaProdFamilyNames.add(qp.Product_Family__c.toLowerCase());	//CRM-5500
                        }
                    }
                }
            }
            //CRM-5500
            set<string> prodNames = new set<string>();
            for(Product_Family__c cs : Product_Family__c.getall().values()){
            	if(setQuotaProdFamilyNames.contains(cs.Family_Name__c.toLowerCase())){
            		prodNames.add(cs.Name);
            	}
            }
            // CRM-5500 ends
            set<string> setQuotaIds = new set<String>(mapMgrNameWRTQuotaId.values());
            string managersNames = String.join(new List<string>(mapMgrNameWRTQuotaId.keySet()), '\',\'');
            string query = 'SELECT id,Name, Total_Commissionable_Amount__c,Product__c,Signing_AE__c,'
                + 'Product__r.Name,Product__r.Family,Related_to_Quota__c,Related_to_Quota__r.Managers__c,Related_to_Quota__r.Owner_Name__c,'
                + 'Related_to_Quota__r.User_Team__c '
                + 'FROM Commission__c '
                + 'WHERE (line_type__c = \'Add\' OR (line_type__c = \'Amend\' AND RecordType.Name != \'Clawback\')) '
                +   'AND (Related_to_Quota__r.Quota_StartDate__c = THIS_MONTH '
                +       'OR (Related_to_Quota__r.Quota_StartDate__c = THIS_YEAR AND Related_to_Quota__r.Current_Quater__c =:brokerRDteam)) '
                +   'AND (Related_to_Quota__r.Managers__c INCLUDES (\''+ managersNames + '\') '
                +       'OR Related_to_Quota__c IN :setQuotaIds) '
                +   'AND (Product__r.Name IN :prodNames OR Product__c IN :setQuotaProdIds) ';	//CRM-5500
            system.debug('query**=='+query);
            return Database.getQueryLocator(query);
        }
        return Database.getQueryLocator('');
    }
    
    global void execute(Database.BatchableContext BC, List<Commission__c> scope) {
        if(scope != null && scope.size() > 0){
            system.debug('No. of Comm: '+ scope.size());
            for(Commission__c comm : scope){
                list<string> managers = String.isNotBlank(comm.Related_to_Quota__r.Managers__c) ? comm.Related_to_Quota__r.Managers__c.split(';') : null;
                //system.debug('team:: ' + comm.Related_to_Quota__r.User_Team__c + ', isMgr= ' + comm.Related_to_Quota__r.User_Team__c == managersTeam);
                if(managers == null || (comm.Related_to_Quota__r != null && comm.Related_to_Quota__r.User_Team__c == managersTeam)){
                    managers = new list<string>{comm.Related_to_Quota__r.Owner_Name__c};
                    system.debug('added quota owner--> '+ managers);
                }                
                system.debug('MGRs::'+managers);
                if(managers != null && managers.size() > 0 && comm.Product__r != null){
                	string commProdName = comm.Product__r.Name;
                    for(string mgrName : managers){
                        Quota__c mgrQuota = mapManagersQuotasWithQP.get(mapMgrNameWRTQuotaId.get(mgrName));
                        if(mgrQuota == null){
                            continue;
                        }
                        for(Quota_Product__c qp : mgrQuota.Quota_Products__r){
                            if(comm.Product__c == qp.Product_Name__c || (String.isNotBlank(qp.Product_Family__c) && Product_Family__c.getInstance(commProdName) != null && qp.Product_Family__c == Product_Family__c.getInstance(commProdName).Family_Name__c)){	//CRM-5386, updated for family check
                                Quota_Product__c qpToUpdate = mapQPCalculateUpdate.get(qp.Id);
                                system.debug('qptoupdate.id: '+ qpToUpdate);
                                if(qpToUpdate == null){
                                    qpToUpdate = new Quota_Product__c(Id = qp.Id);
                                    qpToUpdate.Sales_Achivement__c = 0.0;
                                    system.debug('qp initialized: '+ qpToupdate);
                                }
                                qpToUpdate.Sales_Achivement__c += comm.Total_Commissionable_Amount__c != null ? comm.Total_Commissionable_Amount__c : 0.0;
                                system.debug('summed up: '+ qpToUpdate);
                                mapQPCalculateUpdate.put(qpToUpdate.Id, qpToUpdate);
                            }
                        }
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        if(mapQPCalculateUpdate != null && mapQPCalculateUpdate.size() > 0){
            system.debug('ToUpdate: : '+ mapQPCalculateUpdate.values());
            update mapQPCalculateUpdate.values();
        }
    }
}