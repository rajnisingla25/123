//
// (c) 2015 Appirio, Inc.
//
// Apex Class Name: Account_Hierarchy_Utility
// Description: Its a webservice class to extract account and relationship records.
//
// 16th March 2015    Hemendra Singh Bhati    Original (Task # T-370637)
// 27th April 2015    Hemendra Singh Bhati    Modified (Task # T-381847) - Added Method: getProductList().
//
global class Account_Hierarchy_Utility {
  // Inner class to club account relationship data.
  /*
    global class AccountRelationship {
        webservice String AccountId;
        webservice String AccountName;

    // The Constructor.
    AccountRelationship(String theAccountId, String theAccountName) {
      AccountId = theAccountId;
      AccountName = theAccountName;
    }
    }
  */

  // Inner class to club account fields.
  global class AccountField {
    webservice String FieldName;
    webservice String FieldValue;

    // The Constructor.
    AccountField(String fName, String fValue) {
        FieldName = fName;
        FieldValue = fValue;
    }
  }

  // Inner class to club account details.
  global class AccountDetail {
    webservice String SectionHeader;
    webservice List<AccountField> SectionFields;

    // The Constructor.
    AccountDetail(String sHeader, List<AccountField> sFields) {
        SectionHeader = sHeader;
        SectionFields = sFields;
    }
  }

  // Inner class to club product data.
  global class ProductData {
    webservice String ProductId;
    webservice String ProductName;

    // The Constructor.
    ProductData(String theId, String theName) {
      ProductId = theId;
      ProductName = theName;
    }
  }

    global class AccountDetails{
        webservice String Name;
        webservice String AccountType;
        webservice Decimal TotalAccountValue;
        webservice Decimal TotalHLC;
        webservice Decimal TotalCLC;
        webservice Decimal Offices;
        webservice Decimal Agents;
        webservice String AccountId;
        
        AccountDetails(String valId, String valName, String valType, Decimal valTotalAccountValue,
                        Decimal valTotalHLC, Decimal valTotalCLC,
                        Decimal valOffices, Decimal valAgents){
        AccountId = valId;
        Name = valName;        
        AccountType = (valType == null) ? '' : valType;
        TotalAccountValue = (valTotalAccountValue == null) ? 0 : valTotalAccountValue;
        TotalHLC = (valTotalHLC == null) ? 0 : valTotalHLC;
        TotalCLC = (valTotalCLC == null) ? 0 : valTotalCLC;
        Offices = (valOffices == null) ? 0 : valOffices;
        Agents = (valAgents == null) ? 0 : valAgents;                               
       }
        
    }  
    
    
  /*
  @method      : getAccountName()
  @description : Webservice call to fetch account name.
  @params      : String AccountId
  @returns     : String Account.Name
  */
  webservice static AccountDetails getAccountName(String AccountId) {
    List<Account> theAccount = [SELECT Id, Name,Total_Contract_Value__c,Total_Offices__c ,
                                Total_Agents__c ,Total_CLC__c ,Total_HLC__c , Type  
                                FROM Account WHERE Id = :AccountId];
      AccountDetails ad;
      if (theAccount.size() > 0){
          Account a = theAccount[0];
          ad = New AccountDetails(a.Id,a.Name, a.Type, a.Total_Contract_Value__c,
                        a.Total_HLC__c, a.Total_CLC__c,
                        a.Total_Offices__c, a.Total_Agents__c);
      }
      else {
          ad = Null;
      }
      
        return ad;      
      
      //return theAccount.size() > 0 ? theAccount[0].Name : null;
  }
/*
  // Webservice call to extract all child relationships of an account.
  webservice static List<AccountRelationship> getChildRelationships(String AccountId) {
    List<AccountRelationship> theChildRelationshipRecords = new List<AccountRelationship>();
    for(Account_Relationship__c theAccountRelationship : [SELECT Child_Account__c, Child_Account__r.Name FROM Account_Relationship__c
                                                          WHERE Parent_Account__c = :AccountId]) {
      theChildRelationshipRecords.add(new AccountRelationship(
                theAccountRelationship.Child_Account__c,
                theAccountRelationship.Child_Account__r.Name
      ));
    }
    return theChildRelationshipRecords;
  }
*/
  // Webservice call to extract all child relationships of an account.
  webservice static List<AccountDetails> getChildRelationships(String AccountId) {
    List<AccountDetails> theChildRelationshipRecords = new List<AccountDetails>();
    for(Account_Relationship__c ARs : [SELECT Child_Account__c, Child_Account__r.Name,
                                                          Child_Account__r.Total_Contract_Value__c,Child_Account__r.Total_Offices__c ,
                                                          Child_Account__r.Total_Agents__c ,Child_Account__r.Total_CLC__c ,
                                                          Child_Account__r.Total_HLC__c , Child_Account__r.Type
                                                          FROM Account_Relationship__c
                                                          WHERE Parent_Account__c = :AccountId
                                                          And Is_Parent_Primary__c = True And Active__c = True]) {
      theChildRelationshipRecords.add(new AccountDetails(ARs.Child_Account__c, ARs.Child_Account__r.Name, ARs.Child_Account__r.Type, ARs.Child_Account__r.Total_Contract_Value__c,
                        ARs.Child_Account__r.Total_HLC__c, ARs.Child_Account__r.Total_CLC__c,
                        ARs.Child_Account__r.Total_Offices__c, ARs.Child_Account__r.Total_Agents__c));
    }
    return theChildRelationshipRecords;
  }
    
    
  /*
  @method      : getParentRelationships()
  @description : Webservice call to extract all parent relationships of an account.
  @params      : String AccountId
  @returns     : List<AccountDetails>
  */
  webservice static List<AccountDetails> getParentRelationships(String AccountId) {
    List<AccountDetails> theParentRelationshipRecords = new List<AccountDetails>();
    for(Account_Relationship__c ARs : [SELECT Parent_Account__c, Parent_Account__r.Name, 
                                       Parent_Account__r.Total_Contract_Value__c,Parent_Account__r.Total_Offices__c ,
                                       Parent_Account__r.Total_Agents__c ,Parent_Account__r.Total_CLC__c ,
                                       Parent_Account__r.Total_HLC__c , Parent_Account__r.Type
                                       FROM Account_Relationship__c
                                       WHERE Child_Account__c = :AccountId
                                       And Is_Parent_Primary__c = True And Active__c = True]) {
      theParentRelationshipRecords.add(new AccountDetails(ARs.Parent_Account__c,
                        ARs.Parent_Account__r.Name, ARs.Parent_Account__r.Type, ARs.Parent_Account__r.Total_Contract_Value__c,
                        ARs.Parent_Account__r.Total_HLC__c, ARs.Parent_Account__r.Total_CLC__c,
                        ARs.Parent_Account__r.Total_Offices__c, ARs.Parent_Account__r.Total_Agents__c));
    }
    return theParentRelationshipRecords;
  }
    /*
  webservice static List<AccountRelationship> getParentRelationships(String AccountId) {
    List<AccountRelationship> theParentRelationshipRecords = new List<AccountRelationship>();
    for(Account_Relationship__c theAccountRelationship : [SELECT Parent_Account__c, Parent_Account__r.Name FROM Account_Relationship__c
                                                          WHERE Child_Account__c = :AccountId]) {
      theParentRelationshipRecords.add(new AccountRelationship(
        theAccountRelationship.Parent_Account__c,
        theAccountRelationship.Parent_Account__r.Name
      ));
    }
    return theParentRelationshipRecords;
  }
*/
  /*
  @method      : getAccountDetails()
  @description : Webservice call to fetch account details.
  @params      : String AccountId
  @returns     : List<AccountDetail>
  */
  webservice static List<AccountDetail> getAccountDetails(String AccountId) {
    List<AccountField> theAccountStatusFields = new List<AccountField>();
    List<AccountField> theAccountSummaryFields = new List<AccountField>();
    List<AccountDetail> theAccountDetails = new List<AccountDetail>();
    for(Account theAccount : [SELECT Id, Name, Phone, Account_Status__c, Rating__c, Total_Contract_Value__c, Number_of_Employees__c
                              From Account WHERE Id = :AccountId]) {
      // Account Status Data.
      theAccountStatusFields.add(new AccountField('Name', theAccount.Name));
      theAccountStatusFields.add(new AccountField('Account_Status__c', theAccount.Account_Status__c));

      // Account Summary Data.
      theAccountSummaryFields.add(new AccountField('Phone', theAccount.Phone));
      theAccountSummaryFields.add(new AccountField('Rating__c', theAccount.Rating__c));
      theAccountSummaryFields.add(new AccountField('Total_Contract_Value__c', String.valueOf(theAccount.Total_Contract_Value__c)));
      theAccountSummaryFields.add(new AccountField('Number_of_Employees__c', String.valueOf(theAccount.Number_of_Employees__c)));

      // Build Response Data.
      theAccountDetails.add(new AccountDetail('Account Status', theAccountStatusFields));
      theAccountDetails.add(new AccountDetail('Account Summary', theAccountSummaryFields));
    }
    return theAccountDetails;
  }

  /*
  @method      : getProductList()
  @description : Webservice call to fetch all products.
  @params      : void
  @returns     : List<ProductData>
  */
  webservice static List<ProductData> getProductList() {
    List<ProductData> theProducts = new List<ProductData>();
    for(Product2 theProduct : [SELECT Id, Name FROM Product2 order by createdDate DESC]) {
        theProducts.add(new ProductData(
          theProduct.Id,
          theProduct.Name
        ));
    }
    return theProducts;
  }
}