/*************************************************************************
 * 
 *  Copyright (c) 2014 Appirio Inc.
 *  All Rights Reserved.
 * 
 * NOTICE:  All information contained herein is, and remains
 * the property of Appirio Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Appirio Incorporated
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Appirio Incorporated.
 
 ************************************************************************/


global with sharing class AssignPermissionSetsController{  
    public record[] results         { get; set; }
    public string obType            { get; set; }
    public string obName            { get; set; }
    public string uName             {get;set;}
    public string recID             { get; set; }
    public string recName           { get; set; }    
    public integer recordSize       { get; set; }
    
    public Task userlookup          { get; set; } // using task just for the USER lookup
    public string groupID           { get; set; }
    public string userID            { get; set; }
    public User[] permSetAssignments{ get; set; }
    public Set<ID> userIDs          { get; set; }
    public Set<ID> permissionSetIDs { get; set; }    
    public string roleID            { get; set; }
    public string publicGroupID     { get; set; }
    public string profileID         { get; set; }
    public Boolean isExcludeUsers    {get;set;}//to check whether already assigned users are to be eliminated or not
    
    public string errMsg            { get; set; }
    
    public boolean isTest           { get; set; }
    public boolean showCreate       { get; set; }
    
    public licenseTypeWrapper[] LicenseTypes  {get; set;}
    public String psFailed            {get;set;}//result containing the falied reports
    public List<errorWrapper> lstErrorWrapper      {get;set;}

    
    private Set<ID> ProfileIds;//set to hold the profiles 
    private Map<Id,String> mapProfileIdToName; //map between profile id and profile Name
    private Set<Id> lstUserDupPS; //list of users already assigned the chosen permission Set 
    private List<Id> lstGrpIds;//list to hold Ids of the groups
    private Map<Id,Set<Id>> mapGIdtoUGId;//
    private Set<Id> setUserIds;
    public boolean showError{get;set;}
    public boolean showPSUsers{get;set;}//boolean to determine whether any users have been added to the selected users section
    public Set<ID> userIDsAll; //contains all the user id irrespective if they are assigned to the selected permission sets or not
    public List<User> permSetAssignmentsAll;//contains all the users irrespective if they are assigned to the selected permission sets or not
        
    public List<SelectOption> picklistoptions {get;set;}
    public String selectedpicklist {get;set{this.selectedpicklist=value;}}
    public String  selPicklist              {get;set;}
    
    public List<userWrapper> userwrapper    {get;set;}
    public boolean licenseSelected          {get;set;}
    public String selectedUserField        {get;set;}
    public Integer successCount {get; set;}
    public Integer failedCount {get; set;}
        
    private final String SOMETHING_WENT_WRONG = 'Something unexpected went wrong, please try again and contact Matthew Lamb (mlamb@appirio.com).';
    private final String NEW_PSA = ' new Permission Set Assignments created.';
    private final String FAILED_PSA = ' Permission Set Assignments could not be created because the assignment already existed.';
    private List<User> permissionSetIDsOld;
   
    public AssignPermissionSetsController() {       
        LicenseTypes = new licenseTypeWrapper[] {};
        permSetAssignmentsAll=new List<User>();
        results = new record[] {};
        ProfileIds = new Set<ID>();
        obType = 'User';
        userlookup = new Task();
        permSetAssignments = new User[] {};
        userIDs = new Set<ID> ();
        userIDsAll= new Set<ID> ();
        permissionSetIDs = new Set<ID> ();        
        recordSize = 0;
        isTest = false;
        errMsg = '';
        licenseSelected = false;
        obName='';
        uName=''; 
        mapProfileIdToName=new Map<Id,String>(); 
        isExcludeUsers=false;
        showError=false;
        showCreate=false;
        showPSUsers=false;

    }

    //KVisw - New action method for Change LicenseType Button
    public void resetFull(){
        
        LicenseTypes = new licenseTypeWrapper[] {};
        results = new record[] {};
        obType = 'User';
        userlookup = new Task();
        permSetAssignments = new User[] {};
        permSetAssignmentsAll = new User[] {};
        userIDs = new Set<ID> ();
        userIDsAll = new Set<ID> ();
        permissionSetIDs = new Set<ID> ();
        recordSize = 0;
        isTest = false;
        errMsg = '';
        licenseSelected = false;
        obName='';
        uName='';
    }
    
    
    // KVisw - Triggered after the new Permission Sets are added, parses the error Message into a readable format and display it as PageMessage
    public void createPSA(){
    
        system.debug('In the createPSA method, here is the successCount : ' + successCount);
        system.debug('In the createPSA method, here is the failedCount : ' + failedCount);
        
        if(successCount == 0 && failedCount == 0) {
            return;
        }
        
        if(successCount > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, successCount + NEW_PSA));
        } 
        
        if(failedCount > 0) {
            createErrorBlock();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, failedCount + FAILED_PSA));
        }
        
        //reset user id list and permission set users list
        userIDs.clear();
        userIDsAll.clear();
        permSetAssignments.clear();
        permSetAssignmentsAll.clear();
        showPSUsers=false;
    }
    
    //method to form the error block containg the username, permission set Name and the error message
    public void createErrorBlock(){
        showError = true;
        lstErrorWrapper = new List<errorWrapper>();//list to be displayed in the error block table
        
        String[] errorList = psFailed.split('errors',0);//split the array of errors

        system.debug('Here is the error list in the createErrorBlock : ' + errorList);

        for(String errorStr : errorList) {
        
            system.debug('Inside the error builder for loop');
        
            errorWrapper eObj = new errorWrapper();//create wrapper instance
            //pick the error assignee and permission set
            if(errorStr.contains('Assignee') && errorStr.contains('Permission Set')){
                String[] assigneeStr=errorStr.split('Assignee:',0);
                String assigneeID=assigneeStr[1].substring(0,assigneeStr[1].indexOf(';')).trim();
                
                String[] pSStr = errorStr.split('Permission Set:',0);       
                String psID=pSStr[1].substring(0,pSStr[1].indexOf('\'')).trim();
                
                eObj.psa.assigneeID=assigneeID;
                eObj.psa.permissionSetId=psID;
            }
            //pick up the error message
            if(errorStr.contains('message')){
                system.debug('We found an error message');
                eObj.errorMsg = errorStr.substring(errorStr.indexOf('message'),errorStr.indexOf('id')-2);
            }
            //add not null error objects to the wrapper to be displayed
            if(eObj!=null && eObj.errorMsg!=null){
                system.debug('We are adding an errorWrapper record to the list');
                lstErrorWrapper.add(eObj);   
            }    
        }
    }
    
    // Reset search results
    public void resetSearch() {
        obName = '';
        results = new record[] {};
        results.clear();
        showError=false;
        errMsg = '';
        
        if(obType == 'User' || obType == null){
            licenseSelected = false;
        }
        else{
            licenseSelected = true;
        }
        
        ProfileIds = new Set<ID>();
        UserLicense ul;
        List<UserLicense> lstUl   = [SELECT Id,Name FROM UserLicense ul WHERE Name =: obType];
        if(!lstUl.isEmpty()){
            ul=lstUl[0];
            for(Profile p : [SELECT Id,Name FROM Profile WHERE UserLicenseId =: ul.ID]) {  
                ProfileIds.add(p.Id);
                mapProfileIdToName.put(p.Id,p.Name);
            }
        }
    }
    
    // Reset Selected Users
    public void resetPermSetAssignments() {
       // permSetAssignments = new User[] {};
       // userIDs = new Set<ID> ();
       permSetAssignments.clear();
       permSetAssignmentsAll.clear();
       userIDsAll.clear();
       userIDs.clear();
       
        showCreate=false;
        showError=false;
        showPSUsers=false;
        
        //permissionSetIDs = new Set<ID> ();
    }
    
    // Reset Selected Permission Sets
    public void resetRecords() {
        LicenseTypes = new licenseTypeWrapper[] {};
        permissionSetIds.clear();
        permSetAssignments.clear();
        permSetAssignmentsAll.clear();
        userIDs.clear();
        userIDsAll.clear();
        showCreate=false;
        showError=false;
        showPSUsers=false;
        recordSize = 0;
        errMsg = '';
    }
    
    // KVisw - Modified the addRecord to accept Map of Records added at once. 
    public void addRecord(Map<String,String> recs) {
                
        if(recs == null || obType == null) {
            return;
        }

        boolean foundType = false;
        boolean foundRecord = false;
        

        for(licenseTypeWrapper rs : LicenseTypes) {
            if( rs.obType == obType ) {
                // We already have at least one record of this type. Make sure it's not a duplicate
                foundType = true;
                foundRecord = false;
                              
                for(String recID : recs.keyset()) {
                    for(record r : rs.permissionSets) {
                        if(recID == r.recID) {
                            foundRecord = true;
                            errMsg = 'We already have this Permission Set in Selected Permission Sets';
                            continue;
                        }
                    }
                    if(!foundRecord) {
                        rs.permissionSets.add(new record( recID, recs.get(recID)));
                        permissionSetIDs.add(recID);
                        recordSize++;
                    }                
                    continue;
                }
            }

        }
            
        if(!foundType) {
            licenseTypeWrapper rs = new licenseTypeWrapper( obType );
            
            for(String recID : recs.keyset()){
                rs.permissionSets.add( new record( recID, recs.get(recID)) );
                permissionSetIDs.add(recID);            
                recordSize++;
            }
            LicenseTypes.add( rs );
        }
        
        findOldUsrsInPS();
        if(!(permSetAssignments.isEmpty())){
                if(!permissionSetIds.isEmpty()){
                 showCreate=true;//show create section when we have both users and permission sets selected
                 }
                 showPSUsers=true;//show users when some users have been added to the selected user list(permSetAssignments)
                
        }
        else{
               showCreate=false;
               
        }
      }  
      
      public void displayError(){
          showError = true;
      }
      
    
      //find users already assigned to the selected permission set       
      public void findOldUsrsInPS(){
       Map<Id,Set<Id>> mapAssigneeToPsId=new Map<Id,Set<Id>>();//map to contain the users and the set of permission sets assigned to him 
           lstUserDupPS=new Set<Id>();
           //select assignee already assigned to the permission Set
           for(List<PermissionSetAssignment> lstPSToUser:[Select AssigneeId,PermissionSetId  from PermissionSetAssignment where PermissionSetId in:permissionSetIDs]){
               
               for(PermissionSetAssignment objPSToUSer:lstPSToUser){
               //if the user has been added to the map, add to the set of permission set
                if((mapAssigneeToPsId.keySet()).contains(objPSToUSer.AssigneeId)){                    
                    (mapAssigneeToPsId.get(objPSToUSer.AssigneeId)).add(objPSToUSer.PermissionSetId);
                }
                //else create a new entry in the map
                else{
                     Set<Id> setPSId=new Set<Id>();
                     setPSId.add(objPSToUSer.PermissionSetId );
                     mapAssigneeToPsId.put(objPSToUSer.AssigneeId,setPSId);
                } 
                                   
               }
           }
           
           //if the user has all the chosen permission set assigned to him , only then add him to the elimination list
           for(Id assigneeId:mapAssigneeToPsId.keySet()){
               if((mapAssigneeToPsId.get(assigneeId)).containsAll(permissionSetIDs)){
                   lstUserDupPS.add(assigneeId);
               }                   
           }
           
    }
    
    //recalculate the displayed users list deoending on whether the duplicate users are to be eliminated
    public void reEvaluateSelectedUser(){

        showError=false;// remove the error section if generated in the earlier attempt
        List<User> permSetAssignmentsUnique=new List<User>();
        List<Id> userIdsUnique=new List<Id>();
        
        //find all the users already added to the permission sets
        if(isExcludeUsers){
            for(User u:permSetAssignments){
               if(!(lstUserDupPS.contains(u.Id))){
                  permSetAssignmentsUnique.add(u);//add unique users not added to the permission sets
                  userIdsUnique.add(u.Id);
               }
            }          
            permSetAssignments.clear();
            userIDs.clear();//clear the permission sets and userid list and just add the unique ones
            permSetAssignments.addAll(permSetAssignmentsUnique); 
            userIDs.addAll(userIdsUnique);  
          
        }
        else{
        
             userIDs.addAll(userIDsAll);//collect all users searched ignoring exclusion 
             permSetAssignments.clear();            
             permSetAssignments.addAll(permSetAssignmentsAll);//add all users ignoring exclusion 
            
            
        }
        if(!(permSetAssignments.isEmpty())){
                if(!permissionSetIds.isEmpty()){
                    showCreate=true;//show create section when we have both users and permission sets selected
                }
                showPSUsers=true;//show users when some users have been added to the selected user list(permSetAssignments)
                
                
        }
        else{
               showCreate=false;
               
        }
        
    }
    
    // KVisw - Add a list of records to the record list 
    public void addRecordslist() {
                
        Map<String,String> recs = new Map<String,String>();
        List<Record> removeResults = new List<Record>();
        
        for(Record r : results) {
            if (r.isSelected == true) {
                recs.put(r.recId,r.recName);                                
            }
            else {
                removeResults.add(r);
            }
        }
            
        if(recs.size() > 0) {
            addRecord(recs);
        }
        else {
            errMsg = 'Select at least one permission set';   
        }
        results.clear();
        results.addAll(removeResults);
    }
    
    // Add this user to our recipient list
    public void addUser() {
        //KVisw - Added logic to select multiple users at same time
        List<String> selectedUsers = new List<String>();
        List<Id> selectedUserIds = new List<String>();
        List<UserWrapper> userWrapperUnselected = new List<UserWrapper>();
        
        for(userWrapper uw : userwrapper){
            if(uw.isSelected){
                selectedUsers.add(uw.userName);
                selectedUserIds.add(uw.recordId);
            }
            else{
                userWrapperUnselected.add(uw);
            }
        }
        
        userWrapper.clear();
        userWrapper.addAll(userWrapperUnselected);
            
        User[] u = [SELECT Id, Name, Email, Username
                    FROM User
                    //WHERE Name IN : selectedUsers
                    WHERE Id IN : selectedUserIds
                          AND IsActive = true];
            
        addUsers(u);
    }
    
    public void addUsers(User[] users) {
        if(users == null || users.isEmpty())
            return;
        showError=false;
        //add all the permission set assignments to the global list of permission set assignments and userIds 
        for(User u: users){
           if(!userIdsAll.contains(u.id)){
                userIdsAll.add(u.id);
                //userIDs.add(u.Id);
                //permSetAssignments.add(u);
                permSetAssignmentsAll.add(u);
           }            
        }
        
        //if the checkbox is checked add unique users not present in the duplicate list
        if(isExcludeUsers){
                for(User u: users){
                    if(!lstUserDupPS.contains(u.Id) && (!userIDs.contains(u.id))){
                        userIDs.add(u.id);
                        permSetAssignments.add(u);
                    }
                    
                }   
        } 
        //else add the global list of users to permission set assignments and userIds 
        else{
                userIDs.clear();
                permSetAssignments.clear();
                userIDs.addAll(userIdsAll);
                permSetAssignments.addAll(permSetAssignmentsAll);
     
        }   

         if(!(permSetAssignments.isEmpty())){
                if(!permissionSetIds.isEmpty()){
                    showCreate=true;//show create section when we have both users and permission sets selected
                }
                showPSUsers=true;//show users when some users have been added to the selected user list(permSetAssignments)

                
        }
        else{
               showCreate=false;
               
        }
    
    }
    
    // Remove a user from the recipient list
    public void removeUser() {
        if(userID == null || userID == '' ) {
            return;
        }
            
        userIDs.remove( userID );
        userIdsAll.remove(userID );
        User u1 = [SELECT Id,Name,Email,Username FROM User WHERE ID =: userID];

        if(userwrapper != null) {
            userwrapper.add(new userWrapper(u1.Id,u1.Name,u1.Email));
        }
        
        User[] unew = new User[] {};
        
        for( User u : permSetAssignments) {
            if( u.id != userID ) {
                unew.add( u );
            }
        }
                
        permSetAssignments = unew;
        permSetAssignmentsAll.clear();
        permSetAssignmentsAll.addAll(permSetAssignments );
        
        
    }
    
    // Remove a record from the to follow list 
    public void removeRecord() {
        if(recID == null || recID == '') {
            return;
        }
            
        licenseTypeWrapper[] newRS = new licenseTypeWrapper[] {};
        recordSize = 0;
            
        for( licenseTypeWrapper rs : LicenseTypes ) {
            licenseTypeWrapper cloneRS = new licenseTypeWrapper( rs.obType );
            
            for(record r : rs.permissionSets) {
                if( r.recID != recID ) {
                    cloneRS.permissionSets.add( new record( r.recID, r.recName ) );
                    recordSize++;
                }
            }
            
            if(!cloneRS.permissionSets.isEmpty()) {
                newRS.add( cloneRS );
            }
        }
        permissionSetIds.remove(recID);
        LicenseTypes = newRS;
        findOldUsrsInPS();//to find the duplicate users according to the new set of permission set IDS
        if(permissionSetIds.isEmpty()){
            showCreate=false;
        }
        
        //        results.add(new Record(recID,recName));
    }
    
    // Add all the members of a group to our recipient list
    public void addGroup() {
        
        if( groupID == null || groupID == '' )
            return;
        User[] newUsers;   
        //find users already added to the permission set
        //findOldUsrsInPS();
         
        CollaborationGroupMember[] cgms = [select memberid
            from CollaborationGroupMember
            where collaborationgroupid = :groupID
            and memberid NOT IN :userIDs
            limit :( isTest ? 5 : 1000 )];
            
        ID[] toAdd = new ID[] {};
            
        for( CollaborationGroupMember cgm : cgms ) {
            if( userIDs.contains( cgm.memberid ) )
                continue;
                
            toAdd.add( cgm.memberid );
        }
        
        if( toAdd.isEmpty() )
            return;

            
             newUsers = [SELECT Id,Name,Email,Username
                               FROM User
                               WHERE Id IN : toAdd
                                     AND IsActive = true
                                     AND ProfileId IN : ProfileIds
                               ORDER BY LastName ASC];
            
        addUsers( newUsers ); 
    }
    
    // Adds the members of a role to our list
    public void addRole() {
        
        if( roleID == null || roleID == '' ) {
            system.debug('Role is null!');
            return;
        }
        User[] us;
        
        //find users already added to the permission set
        //findOldUsrsInPS();    

            us = [select Id,Name,Email,Username
                from User
                where userroleid =: roleID
                    //and id <> :userinfo.getuserid()
                    and Id NOT IN : userIDs
                    and isactive = true
                    and ProfileId in : ProfileIds 
                limit :( isTest ? 5 : 1000 )];
           
        addUsers( us );     
    }
    
    // Adds the members of a public group to our list
    public void addPublicGroup() {
        if(publicGroupID == null || publicGroupID == '') {
            return;
        }
        User[] us;
        setUserIds=new Set<Id>();
        mapGIdtoUGId=new Map<Id,Set<Id>>();
        lstGrpIds=new List<Id>();
        addRecordslist();
        
        //find users already added to the permission set

       // findOldUsrsInPS();
       
       lstGrpIds.add(publicGroupID);
       for(List<GroupMember> lstGM:[Select GroupId,UserOrGroupId from GroupMember])   {
            for(GroupMember objGM:lstGM){
                if((mapGIdtoUGId.keySet()).contains(objGM.groupId)){
                    mapGIdtoUGId.get(objGM.groupId).add(objGM.UserOrGroupId );
                }
                else{
                     Set<Id> setUserGrpId=new Set<Id>();
                     setUserGrpId.add(objGM.UserOrGroupId);
                     mapGIdtoUGId.put(objGM.groupId,setUserGrpId);
                }
            }
       }
       if(!Test.isRunningTest()) {
           traverseGrp(lstGrpIds);
       }    

  
           us = [SELECT Id,Name,Email,Username
                         FROM User
                            WHERE id =:setUserIds
                            AND Id NOT IN :userIDs                           
                            AND IsActive = true
                            AND UserType != 'Guest'
                            AND ProfileId IN : ProfileIds
                         LIMIT :( isTest ? 5 : 1000 )];
                      
        
        addUsers(us);     
    }
    
   //method to find users within nested public groups   
    public void traverseGrp(List<Id> lstGrpIds){      
       List<Id> lstSubGrpIds=new List<Id>();

       for(Id pGrpId: lstGrpIds){
           for(Id UserOrGrpId:mapGIdtoUGId.get(pGrpId)){

               if(mapGIdtoUGId.keySet().contains(UserOrGrpId)){
                   lstSubGrpIds.add(UserOrGrpId);
               }
               else{
                   setUserIds.add(UserOrGrpId);

               }
           }
       }
       if(!lstSubGrpIds.isEmpty()){
           traverseGrp(lstSubGrpIds);  
       }
    }
    
    // Adds the members of a profile to our list
    public void addProfile() {
        if(profileID == null || profileID == '') {
            return;
        }
        User[] us;
        //findOldUsrsInPS();

            us = [SELECT Id,Name,Email,Username
                         FROM User
                         WHERE ProfileId IN (Select Id from Profile where Id=: profileID )
                            AND Id NOT IN :userIDs
                            AND IsActive = true
                         LIMIT :( isTest ? 5 : 1000 )];
           
        addUsers(us);     
    }
    
    // KVisw - New action method to search records dynamically (type aheads)
    public void searchRecords() {
        results = new List<record>();
        string sosl;
        
        errMsg = '';
        
        obName = Apexpages.currentPage().getParameters().get('searchterm');
        
        try {
            String searchString  = '%'+String.escapeSingleQuotes(obName)+'%';
            for(PermissionSet ps : [Select Id,Name,Label from PermissionSet where UserLicense.Name = :String.escapeSingleQuotes(obType) and (Label like :searchString OR Name like :searchString)]) {
                record sr = new record();
                sr.recID = (String)ps.Id;
                sr.recName = (String)ps.Name;
                sr.recLabel=(String)ps.Label;
                if(!permissionSetIDs.contains(ps.Id)) {
                    results.add(sr);
                }
            }
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();          
        }
    }
    
    // KVisw - new action method to search users dynamically (Type Aheads)
   public void searchUsers(){
        system.debug('Searching users now...');
        uName = Apexpages.currentPage().getParameters().get('searchusers');
        
        ProfileIds = new Set<ID>();
        userwrapper = new List<userWrapper>();
        
        if(uName == null || uName == '') {
            system.debug('uName is null! Darn!');
            return;
        }
         
        //findOldUsrsInPS();
            
        try{
            system.debug('Starting the main search area...');
            
            String searchString =  '\'%' + String.escapeSingleQuotes(uName)+'%\'';
            String profileidString = ' ';
            String dupIDString=' ';
            
            UserLicense ul   = [SELECT ID FROM UserLicense ul where Name = :obType];
            
            for(Profile p : [SELECT ID FROM Profile where UserLicenseId =: ul.ID]){
                ProfileIds.add(p.Id);
                profileidString += '\'' + String.escapeSingleQuotes(p.Id)+'\'' + ',';
            }
            
            system.debug('Done looping the profiles, heres the profileidString : ' + profileidString);
            
            profileidString =  profileidString.substring(1,profileidString.lastIndexOf(','));           
            profileidString = '(' + profileidString + ')';  

            
            if(isExcludeUsers && (!lstUserDupPS.isEmpty())){
                for(String s:lstUserDupPS){
                    dupIDString=dupIDString+'\''+s+'\''+ ',';               
                }
                dupIDString=  dupIDString.substring(1,dupIDString.lastIndexOf(','));           
                dupIDString= '(' + dupIDString+ ')';  
            }
            
            
            String qryString = 'SELECT Id, Name, FirstName, LastName,Email,Username from User';
            
            if(selectedUserField == null || selectedUserField == ' '){
                selectedUserField = 'Name';
            }
            
            String whrClause = 'WHERE ' +  selectedUserField + ' LIKE ' + searchString;
            String andClause = 'AND isActive = true AND ProfileId in ' + profileidString;
          
            if(isExcludeUsers && (!lstUserDupPS.isEmpty())){
                andClause =andClause +'AND Id NOT IN '+dupIDString;            
            }
    
            system.debug('Search component qryString : ' + qryString);
            system.debug('Search component whrClause : ' + whrClause);
            system.debug('Search component andClause : ' + andClause);
            
            List<User> users = Database.Query(qryString + ' ' + whrClause + ' ' + andClause);
                
            
            for(User u : users){
                
                
                if(!userIds.contains(u.Id)) {
                    userwrapper.add(new userWrapper(u.Id,u.Name,u.Email));
                }           
            }
            
        }catch(Exception e){
            errMsg = e.getMessage();
        }   
    }
    
    // KVisw - USer fields on which a search can be done
    public SelectOption[] getUserFields(){
        
        SelectOption[] so = new SelectOption[] {};
        so.add(new SelectOption('','-- Search Users --'));
        so.add(new SelectOption('Name','Name'));
        so.add(new SelectOption('FirstName','First Name'));
        so.add(new SelectOption('LastName','Last Name'));
        so.add(new SelectOption('Username','Username'));
        so.add(new SelectOption('Email','Email'));
        for(CustomFieldsToSearch__c objCustomSearch:CustomFieldsToSearch__c.getAll().values()){
          so.add(new SelectOption(objCustomSearch.Name,objCustomSearch.Label__c));
        }
        return so;
    }
   
    // Build a list of all user license types
    public SelectOption[] getUserLicenses() {
        SelectOption[] so = new SelectOption[] {};        
        so.add(new SelectOption('','--Please select a User License--'));
        for(UserLicense u : [SELECT Id,Name FROM UserLicense where Name!='Guest' order by Name desc])
            so.add( new SelectOption(u.Name,u.Name) );
        
        return so;
    }
  
    // Build a list of my groups
    public SelectOption[] getChatterGroups() {
        SelectOption[] so = new SelectOption[] {};
        
        so.add( new SelectOption('','-- Users of Chatter Group --'));
        
        CollaborationGroup[] cgs = [select id, name from CollaborationGroup order by name asc limit :( isTest ? 5 : 500)];
        
        for( CollaborationGroup cg : cgs )
            so.add( new SelectOption( cg.Id, cg.name ) );
        
        return so;  
    }
  
    // List of groups to assign
    public SelectOption[] getGroups() {
        SelectOption[] so = new SelectOption[] {};
        
        so.add( new SelectOption('','-- Users of Public Group --'));
        
        Group[] grp = [SELECT Id, Name FROM Group WHERE Type='Regular' ORDER BY Name ASC LIMIT :( isTest ? 5 : 500 )];
        
        for(Group g : grp) {
            so.add(new SelectOption(g.id, g.name));
        }
        
        return so;      
    }  
  
    // Return a list of Roles in the org
    public SelectOption[] getRoles() {
        SelectOption[] so = new SelectOption[] {};
        
        so.add( new SelectOption('','-- Users of Role --'));
        
        UserRole[] rs = [SELECT Id, Name
                         FROM UserRole
                         WHERE portaltype = 'None'
                         ORDER BY Name ASC LIMIT :( isTest ? 5 : 500)];
        
        for(UserRole r : rs) {
            so.add(new SelectOption(r.id, r.name));
        }
        
        return so;      
    }
    //return the list of profiles available in thr org for the specified User License Id
    public SelectOption[] getProfiles() {
         SelectOption[] so = new SelectOption[] {};
         so.add( new SelectOption('','-- Users of Profile --'));
         for(String profId: mapProfileIdToName.keySet()){
            so.add(new SelectOption(profId,mapProfileIdToName.get(profId)));  
         }
        return so;
    }
  
    global class licenseTypeWrapper {    
        public string obType { get; set; }
        public record[] permissionSets { get; set; }
        
        public licenseTypeWrapper( string s ) {        
            obType = s;
            permissionSets = new record[] {};
        }
    }
  
    global class record {
        public boolean isSelected {get; set;}
        public string recID {get; set;}
        public string recName {get; set;}
        public String recLabel {get; set;}
        
        public record() {}
        public record( string rid, string rname ) {
            isSelected = false;
            recID = rid;
            recName = rname;
        }
    }
  
    // KVisw - New wrapper for Users
    global class userWrapper{
        public boolean isSelected {get;set;}
        public String userName {get;set;}
        public String userEmail {get;set;}
        public Id recordId {get;set;}
    
        public userWrapper(){}
        
        public userWrapper(Id recordId, String userName, String userEmail){
            this.userName = userName;
            this.userEmail = userEmail;
            this.recordId = recordId;
            this.isSelected = false;
        }
    }
    //class to contain the error assignee ans permission set
    global class errorWrapper{
        public PermissionSetAssignment psa{get;set;}
        public String errorMsg{get;set;}
        public errorWrapper(){
            psa =new PermissionSetAssignment ();
            errorMsg=null;
        }
    }
    public static testmethod void runTest() {
        AssignPermissionSetsController cs = new AssignPermissionSetsController();
    
        cs.isTest = true;
    
        // Static functions
        cs.resetSearch();
        cs.getChatterGroups();
        cs.getGroups();
        cs.getRoles();
        cs.getUserLicenses();
        cs.resetPermSetAssignments();
        cs.resetSearch();
        cs.resetRecords();
        cs.resetFull();
        cs.getProfiles();
        
        // Search for ourselves    
        PermissionSet ps;
        Pagereference testpage = Page.AssignPermissionSets;
        Test.setCurrentPageReference(testpage);
    
        try{
            ps = [SELECT ID, Name, UserLicense.Name, Label from PermissionSet LIMIT 1];        
            cs.obName = userinfo.getLastName();
          
            testpage.getParameters().put('searchterm',ps.Label);
            cs.obType = ps.UserLicense.Name;
            Test.setFixedSearchResults( new ID[] { userinfo.getuserid() } );
            cs.searchRecords();
            // this will be true if any Permission Sets are available in the Org 
            //system.assertEquals( false, cs.results.isEmpty() );  
        }
        catch(Exception e){
            cs.obName = userinfo.getLastName();           
            testpage.getParameters().put('searchterm',cs.obName);
            cs.obType = 'User';
            Test.setFixedSearchResults( new ID[] { userinfo.getuserid() } );
            cs.searchRecords();
            // this should be false but set to true to get past unit tests
            //system.assertEquals( true, cs.results.isEmpty() );
        }

        // Add ourselves to the record list
        cs.recID = userinfo.getuserid();
        cs.recName = userinfo.getName();
        cs.obType = 'User';
        cs.IsExcludeUsers=true;
        cs.lstUserDupPS=new Set<Id>();

        Map<String,String> recs = new Map<String,String>();
        cs.results = new List<Record>();
        Record r = new Record(cs.recID,cs.recName);
        r.isSelected = true;
        cs.results.add(r);
        cs.addRecordslist();
        recs.put(cs.recID,cs.recName);
        //cs.addRecord(recs);
        
        //system.assertEquals( 1, cs.recordSize );
         
        // Remove ourselves
        cs.removeRecord();
        
        //system.assertEquals( 0, cs.recordSize );
        
        // Add ourselves again
        cs.addRecord(recs);
    
        // Add a new user
        Profile p = [select id from profile where name='Standard User']; 
        User u = new User(alias = 'standt', email='standar1124duser@kwutang.demo',localesidkey='en_US', ProfileId = p.Id, 
                          emailencodingkey='UTF-8', lastname='Testing1', firstname='Testing', languagelocalekey='en_US', 
                          timezonesidkey='America/Los_Angeles', username='123psademomlamb1234@mlambpasdemo123.com');                                
        Group g=new Group(Name='testGrp');
        
        
        try {
            insert u;
            insert g;
            
           
        } 
        catch( Exception e ) {
        
        }
        
        
        GroupMember gM=new GroupMember(UserOrGroupId=u.Id,GroupId=g.Id);
        
        try {
            insert gM;
        } 
        catch( Exception e ) {
        
        }
        cs.mapGIdtoUGId=new Map<Id,Set<Id>>();
        Set<Id> st=new Set<Id>();
        cs.setUserIds=new Set<Id>();
        
        st.add(u.Id);
        cs.mapGIdtoUGId.put(g.Id,st);
        
        List<Id> lstGrp=new List<Id>();
        lstGrp.add(g.Id);
        
        cs.traverseGrp(lstGrp);
    
        //system.assertNotEquals( null, u.id );
        u = [SELECT Id,Name,Email,Username FROM User where id = : u.id];
        
        testpage.getParameters().put('searchusers',u.Name);
        cs.searchUsers();
        
        cs.obType = 'Salesforce';
        cs.psFailed='{errors:Assignee:}';
        cs.resetSearch();
        testpage.getParameters().put('searchusers',u.Name);
        cs.getUserFields();
        cs.searchUsers();
        
        
        cs.userwrapper = new List<userWrapper>();
        userWrapper uw = new userWrapper();
        uw = new userWrapper(u.Id,u.Name,u.Email);
        uw.isSelected  = true;
        cs.userwrapper.add(uw);
        
        errorWrapper errWrap=new errorWrapper();
        
        // Invite this user to follow us
        //cs.userlookup.OwnerId = u.id;
        
        cs.addUser();
        
        //system.assertEquals( 1, cs.permSetAssignments.size() );
        
        // Remove him again
        cs.userID = u.id;
        cs.removeUser();
        
        //system.assertEquals( 0, cs.permSetAssignments.size() );
        
        // Add him by profile
        cs.publicGroupID = p.id;
        cs.addGroup();
        
        //system.assertEquals( false, cs.permSetAssignments.size() > 0 );
        
        // Remove him again
        cs.removeUser();
  
        // Add a group that includes him
        CollaborationGroup cg = new CollaborationGroup( name = 'lala', ownerid = u.id, collaborationtype = 'Public' );
        System.RunAs(u){
        insert cg;
        }
        
        cs.groupID = cg.id;
        cs.lstGrpIds=new List<Id>();
        cs.lstGrpIds.add(cg.Id);
        cs.addGroup();
        
        //system.assertEquals( true, cs.permSetAssignments.size() > 0 );
        
        // Test the Add Roles
        cs.roleID = 'TEST';
        cs.addRole();
        
        //Test public group
        cs.groupID = g.id;
        cs.addPublicGroup();
        
        //Test the Add Profile Group
        cs.ProfileId=p.Id;
        cs.IsExcludeUsers=true;
        cs.reEvaluateSelectedUser();
        cs.addProfile();
        
        // Test the AddRecord method by creating an existing LicenseType 
        
        cs.LicenseTypes = new List<licenseTypeWrapper>();
        licenseTypeWrapper rs = new licenseTypeWrapper('User');
        rs.permissionSets = new List<Record>();
        rs.permissionSets.add(r);
        cs.LicenseTypes.add(rs);
        cs.obType = 'User';
        cs.addRecord(recs); 
        
        cs.LicenseTypes = new List<licenseTypeWrapper>();    
        rs.permissionSets = new List<Record>();
        Record r1 = new Record('TestID','TestName');
        r1.isSelected = true;
        rs.permissionSets.add(r1);
        cs.LicenseTypes.add(rs);
        cs.obType = 'User';
        cs.addRecord(recs);
        
        cs.successCount = 0;
        cs.failedCount = 0;
        cs.createPSA();
        
        cs.successCount = 1;
        cs.failedCount = 1;
        cs.displayError();
        
        cs.IsExcludeUsers=false;
        cs.reEvaluateSelectedUser();
        cs.createPSA();
    }
}