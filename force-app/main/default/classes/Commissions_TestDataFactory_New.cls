public without sharing class Commissions_TestDataFactory_New {
    // This method creates a new user.
    public static User createUser(Id userRoleId, Id profileId, Id contactId, String email, String userName, Boolean isInsert,String Team,string manager) {
        User theUser = new User(
            ProfileId = profileId,
            Alias = 'theUser',
            Email = email,
            EmailEncodingKey = 'UTF-8',
           // LastName = 'First',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = userName,            
            Team__c=Team,           
            Managers__c ='ADRIAN MATTHEWS',
            firstname = 'Heather ',
            lastname = 'Riggio'
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
    
    public static Account createAccount(String theName, string Email1, id rectypidaccount, string street,string city,string state,string pcode,string type,id owner,Boolean isInsert) {
        Account theAccount = new Account(
            Name = theName,
            ShippingStreet = Street,
            ShippingCity = City,
            ShippingState = State,
            ShippingPostalCode = pcode,
            Primary_Email__c = Email1,
            RecordTypeId = rectypidaccount,
            Type = type
        );        
        if(isInsert) {
            insert theAccount;
        }
        return theAccount;
    }
    
    //This method creates a new period.
    public static Period__c createPeriod(String Name,Date Date1,string currentQuater,integer aepercent,integer ownerpercent,Boolean isInsert){
        Period__c period = new Period__c(
            Name='test',
            Start_Date__c = Date1,
            Current_Quater__c = currentQuater,
            Agent_asset_Owner__c = aepercent,       
            asset_Owner__c = ownerpercent
        ); 
        if(isInsert) {
            insert period;
        }
        return period;       
    } 
    
    Public static Payout__c CreatePayout(String Name, id RecordTypeId , Decimal lowlevel ,Decimal Highlevel,Decimal lowAmount, Decimal HighAmount,Boolean isInsert ){
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
        return pa;
    } 

    Public static Quota__c CreateQuota(Id UserId,string userteam,string currentQuater,Id PeriodId,boolean IsKicker, Boolean isInsert){               
        Quota__c  QuotaHandler = new Quota__c(
            User__c = UserId,
            User_Team__c = userteam,
            Current_Quater__c =currentQuater,       
            Period_Name__c=PeriodId,
            Target_Amount__c = 1000,        
            COBROKE_New__c = 1.00,
            Is_Kicker__c = IsKicker,
            Status__c = 'Active'
            //New_Sale_Tier_Changed__c  = TRUE
            //Renewal_Tier_Changed__c = TRUE
        );
        if(isInsert) {
            insert QuotaHandler;
        }
        return QuotaHandler;
           
    }   
    //This method creates a new Asset.
    Public static Asset CreateAsset(id accid,Id rectypidasset,Id aeid,id ownerid,integer TotalNet,id prodid,string linetype,integer price,Boolean isInsert){  
    
        Asset assets = new Asset(
            RecordTypeId = rectypidasset,
            Name = 'FiveStreet',
            Ownerid=ownerid,
            Renewal_Status__c = 'Auto',
            Auto_Renewal__c = 'No',
            Asset_Type__c = Constants.ASSET_TYPE,
            Product2Id = prodid,
            Fulfillment_Status__c = Constants.FULFILLMENT_STATUS,
            Status = Constants.ACTIVE_STATUS,            
            Billing_Period__c = 'Monthly',
            Start_Date__c = system.today(),
            End_Date__c = system.today().addDays(10),
            Line_Type__c = linetype,
            Price = price,
            Sign_in_AE__c = aeid,
            Total_Net__c = TotalNet,
            AccountId = accid,      
            Delta_Price_w_o_Tax__c =-0.5,
            Not_picked__c = true
        );       
        if(isInsert) {
            insert assets;
        }
        return assets;
    }
   
    
      //This method creates a new Commissions.
    Public static Commission__c CreateComm(id assetid,Id QuotaHandlerid, Id ProductId, string linetype,string userteam,id rectypidq,Boolean isInsert){ 
     
        Commission__c  commission1 = new Commission__c(
        RecordTypeId = rectypidq,
        Related_to_Quota__c = QuotaHandlerid,
        Related_to_asset__c = assetid,
        Line_Type__c = linetype,
        user_team__C =userteam,
        Product__c = ProductId,       
        Commissionable_Amount2__c=5.0,
        Commissionable_Amount3__c=6.0);
        
        if(isInsert) {
            insert commission1;
        }   
        return commission1;
    }
    
    public static Product2 CreateProduct(string productName, string productCode, string productFamily, Integer SNo,Boolean isInsert){
        Product2 product = new Product2(Name = productName,ProductCode = productCode, Family = productFamily,S_No__c = SNo);
        
        if(isInsert){
            insert product;
            system.assertNotEquals(null, product.Id);
        }
        return product;
    }
}