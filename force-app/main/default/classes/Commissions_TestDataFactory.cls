public without sharing class Commissions_TestDataFactory {
  
  // This method creates a new user.
    public static User createUser(Id userRoleId, Id profileId, Id contactId, String email, String userName, Boolean isInsert,String Team) {
        User theUser = new User(
            ProfileId = profileId,
            Alias = 'theUser',
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'First',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = userName,
            Payout_Rate_Month_1__c=1,
            Payout_Rate_Month_2__c=2,
            Payout_Rate_Month_3__c=3,
            Team__c=Team,
            Managers__c ='ADRIAN MATTHEWS'
        );
             if(contactId != null) {
      theUser.ContactId = contactId;
    }
    if(userRoleId != null) {
      theUser.UserRoleId = userRoleId;
    }
    if(isInsert) {
      insert theUser;
    }
    return theUser;
  }    
  
  // This method creates a new Account.
    public static Account createAccount(String theName, string Email1, id rectypidaccount, string type, Boolean isInsert) {
       
        Account theAccount = new Account(
        Name = theName,
        ShippingStreet = 'Test Street',
        ShippingCity = 'City',
        ShippingState = 'State',
        ShippingPostalCode = '12345',
        Primary_Email__c = Email1,
        RecordTypeId = rectypidaccount,
        Type = type);
        
        if(isInsert) {
            insert theAccount;
        }
            return theAccount;
    }

  // This method creates a new contact.
  public static Contact createContact(String firstName, String lastName, Id accountId, Boolean isActive, Boolean isInsert) {
    Contact theContact = new Contact(
            FirstName = firstName,
            LastName = lastName,
            AccountId = accountId,
            Active__c = isActive
    );
    if(isInsert) {
      insert theContact;
    }
    return theContact;
  }

 /* // This method creates a new case.
  public static Case createCase(String subject, String status, String theType, String description, Id contactId,
                                Id accountId, Boolean isInsert) {
    Case theCase = new Case(
            Subject = subject,
            Status = status,
            Type = theType,
            Description = description
    );
    if(accountId != null) {
        theCase.AccountId = accountId;
    }
    if(contactId != null) {
      theCase.ContactId = contactId;
    }
    if(isInsert) {
      insert theCase;
    }
    return theCase;
  }
 */
  //This method creates a new period.
    public static Period__c Createperiod(String Name,Boolean isInsert, Date Date1){
        Period__c period = new Period__c(
        Name='test',
        Start_Date__c = Date1); //Date.today().toStartOfMonth()
        if(isInsert) {
            insert period;
        }
            return period;
       
    }   
  // This method creates a new Quota.
    Public static Quota__c CreateQuota(Id UserId, Id PeriodId,Boolean isInsert){
               
        Quota__c  QuotaHandler = new Quota__c(
        Collection_Target_Amount__c= 10,
        User__c = UserId,
        TP_Units_Sold__c=6,
        Is_Kicker__c = true,
        //User_Team__c = 'Events Team',
        //Current_Quater__c = 'EventTeam',       
        Period_Name__c=PeriodId);      
        
        if(isInsert) {
            insert QuotaHandler;
        }
            return QuotaHandler;
           
    }
    
      // This method creates a new Quota.
    Public static Quota__c CreateQuotanew(ID recordtype, Id UserId, Id PeriodId,Boolean isInsert){
               
        Quota__c  QuotaHandler = new Quota__c(RecordTypeId = recordtype,
        Collection_Target_Amount__c= 10,
        User__c = UserId,
        TP_Units_Sold__c=6,
        Is_Kicker__c = true,
        //User_Team__c = 'Events Team',
        //Current_Quater__c = 'EventTeam',       
        Period_Name__c=PeriodId);      
        
        if(isInsert) {
            insert QuotaHandler;
        }
            return QuotaHandler;
           
    }
   // This method creates a new Product.
    Public static Product2 CreateProduct(String Name,Boolean isInsert){
        Product2 product = new Product2(
        Name = Name,
        Commission_Category__c='tiger',
        S_No__c=12);
       
        if(isInsert) {
            insert product;
        }
            return product;
    }
   // This method creates a new payouts.
    Public static Payout__c CreatePayout(String Name, id RecordTypeId , Decimal lowlevel ,Decimal Highlevel,Decimal lowAmount, Decimal HighAmount,Decimal x1,Decimal y1,Decimal x2,Decimal y2,Boolean isInsert ){
        //id rectypidp = Schema.SObjectType.Payout__c.getRecordTypeInfosByName().get('Collections Past Due Team').getRecordTypeId(); 
        
        Payout__c pa= new Payout__c(
       
        name = Name,
        RecordTypeId = RecordTypeId,
        Low_Level__c=lowlevel ,
        High_Level__c=Highlevel,
        Low_Amount__c=lowAmount,
        High_Amount__c=HighAmount
        );
         if(isInsert) {
            insert pa;
        }
            
        
        //lowValueRD = pa.Low_Amount__c;
        //highValueRD = pa.High_Amount__c;
       // CommissinableAmountCompRD = Componet1RollUpValue;
        
        x1 = pa.High_Level__c;                         
        y1 = pa.Commissionable__c;
        x2 = pa.Low_Level__c;  
        y2 = pa.Commissionable__c;
        
        return pa;
    }
   
    // this method creates a new Payment History.
       /*
       Public static Payment_History__c CreatePaymentHistory(String Name,ID UserId, Id AccountId,Boolean isInsert){
            Payment_History__c ph= new Payment_History__c(
            Name=Name,
            Bill_To_Account__c= AccountId,
            OwnerId=UserID,
            Transaction_Amount__c = 100,
            CreatedByid= UserId);
           if(isInsert) {
            insert ph;
        }
            Map<Id,Payment_History__c> PaymentHistory = new Map<Id,Payment_History__c>();
            PaymentHistory.put(ph.id,ph);
             return ph;
        }
        */
        
        Public static Zuora__Payment__c CreateZuoraPayment(String Name,Id Accid,String Paymentmethod,DateTime effectiveDate,double amount,Boolean isInsert){
           
            Zuora__Payment__c payment = new Zuora__Payment__c (
            Name=Name,
            Zuora__BillingAccount__c = accid,
            Zuora__PaymentMethod__c = Paymentmethod,
            Zuora__EffectiveDate__c = effectiveDate,
            Zuora__Amount__c = amount);
            
            if(isInsert) {
            insert Payment;
            }
            
            Map<Id,Zuora__Payment__c > PaymentHistory = new Map<Id,Zuora__Payment__c >();
            PaymentHistory.put(Payment.id,Payment);
            return Payment;
            
        }
      //This method creates a new Commissions.
    Public static Commission__c CreateComm(Id QuotaHandlerid, Id ProductId, id rectypidq, id phId ,Boolean isInsert){   
     
        Commission__c  commission1 = new Commission__c(
        RecordTypeId = rectypidq,
        Related_to_Quota__c = QuotaHandlerid,
        Product__c = ProductId,
        Other_Product__c ='Top Producer',
        //Payment_History__c =PhId ,
        //CFCB_New_w_o_Qualifier_Comm_ble_Amount2B__c=30.0,
        //CFCB_NEW_w_Qualifier_Comm_ble_Amount2A__c=40.0,
        //CFCB_RNW_w_Qualifier_Payout_Rate2C__c = 20.00,
        //CFCB_RNW_w_o_Qualifier_Payout_Rate2D__c = 15.00,
        Commissionable_Amount2__c=5.0,
        Commissionable_Amount3__c=6.0);
        
       if(isInsert) {
            insert commission1;
        }
            
        
        set<id> allCommissionIds =new set<id>();
        allCommissionIds.add(commission1.id);
        return commission1;
    }  
    
     //This method creates a new Asset.
    Public static Asset CreateAsset(Id rectypidasset, Id uid, id prodid , Boolean isInsert){  
    
        Asset assets = new Asset(
        RecordTypeId = rectypidasset,
        Name = 'FiveStreet',
        Ownerid=uid,
        Renewal_Status__c = 'Auto',
        Auto_Renewal__c = 'No',
        Asset_Type__c = 'Constants.ASSET_TYPE',
        Product2Id = prodid,
        Fulfillment_Status__c = 'Constants.FULFILLMENT_STATUS',
        Status = 'Constants.ACTIVE_STATUS',
        At_Risk__c = false,
        Billing_Period__c = 'Monthly',
        Start_Date__c = system.today(),
        End_Date__c = system.today().addDays(10),
        Line_Type__c = 'renew',
        Price = 10.00,
        Sign_in_AE__c=uid);
       
        if(isInsert) {
            insert assets;
        }
        return assets;
    }


        
  // This method creates a new account relationship.
    public static Account_Relationship__c createAccountRelationship(Id parentAccountId, Id childAccountId, Id contactToId,
                                                                  String contactRole, Boolean isActive, Boolean isInsert) { 
        Account_Relationship__c theAccountRelationship = new Account_Relationship__c(
        Parent_Account__c = parentAccountId,
        Child_Account__c = childAccountId,
        Contact_To__c = contactToId,
        Contact_Role__c = contactRole,
        Active__c = isActive
        );
        if(isInsert) {
            insert theAccountRelationship;
        }
        return theAccountRelationship;
    }

}