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
 */


public class RemovePermissionSetsController {

    // Searching for new records
    public record[] results         { get; set; }
    public string obType            { get; set; }
    public string obName            { get; set; }
    public string recID             { get; set; }
    public string recName           { get; set; }
    public integer recordSize       { get; set; }
    public boolean isTest           { get; set; }
    public string errMsg            { get; set; }
    public string alertMsg          { get; set; }
    public string filterBy {get;set;}
    public string filterId {get;set;}
    public transient Integer successCount {get; set;}
    public transient Integer failedCount {get; set;} 
    /*
        Private constants for filter by options
    */
    private final string PROFILE_FILTER = 'PROFILE';
    private final string ROLE_FILTER = 'ROLE';
    private final string PGROUP_FILTER = 'PUBLIC_GROUP';
    private final string CGROUP_FILTER = 'CHATTER_GROUP';
    
    private final String SUCCESS_MSG = ' Permission Set Assignments removed successfully.';
    private final String FAILURE_MSG = ' Permission Set Assignments could not be removed due to errors.';
    public String defaultSearchTxt {get {return 'Keyword';}}
    public transient string usrSearchTxt {get;set;}
    public Boolean selAllChkBox {get; set;}
    public List<PermissionSetAssignment> psaList {get; set;}
    public boolean isLicenseSelected {get;set;}
    public boolean showCreate {get; set;}
    public List<PermissionSetAssignment> psaRemoveList {get; set;}
    public List<PermissionSet> ps {get; set;}
     
    public RemovePermissionSetsController() {
        filterBy = '';
        filterId = '';
        isLicenseSelected = false;
        isTest = false;
        usrSearchTxt = defaultSearchTxt;
    } 
     
    // Reset search results
    public void resetSearch() {
        obName = '';
        results = new record[] {}; 
        errMsg = '';
        alertMsg = '';
        showCreate = false;
        if(obType != null && obType != '') {
            isLicenseSelected = true;
        } else {
            isLicenseSelected = false;
        }
    }
    
    // Reset search results
    public void resetFull() {
        obName = '';
        obType = '';
        results = new record[] {}; 
        errMsg = '';
        alertMsg = '';
        showCreate = false;
        isLicenseSelected = false;
    }

    // Build a list of all user license types
    public SelectOption[] getUserLicenses() {
        SelectOption[] so = new SelectOption[] {};
        so.add(new SelectOption('','--Please select a User License--'));
        for(UserLicense u : [SELECT Id,Name FROM UserLicense where Name!='Guest' order by Name desc])
            so.add( new SelectOption(u.Name,u.Name) );
        
        return so;
    }
    
    /*
      Perform search on PermissionSet based on the seleted license and 
      provided search criteria
    */
    public void searchRecords() {
        results = new List<record>();
        string sosl;
        
        errMsg = '';
        alertMsg = '';
        
        if( obName == null || obName == '' ) {
            errMsg = 'Please enter a search term.';
            return; 
        }
        
        try {
            String searchString  = obName + '%';
            for(PermissionSet ps : [Select Id,Name, Label from PermissionSet where UserLicense.Name = :String.escapeSingleQuotes(obType) and (Name like :searchString or label like : searchString) ORDER BY Label DESC]) {
                record sr = new record();
                sr.recID = (String)ps.Id;
                sr.recName = (String)ps.Name;
                sr.recLabel = (String)ps.Label;   
                results.add(sr);
            }
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();          
        }
    }
    

    /*
        This method is used to retrieve list of users 
        associated with the selected permission set. Optionally
        it applies filters based on the selected criteria       
    */
    public void showUsers() {       
        String queryString = 'SELECT ID, Assignee.Name, Assignee.Email FROM PermissionSetAssignment';
        String filterClause = 'PermissionSetId =: recId';
        if(usrSearchTxt != null && usrSearchTxt != defaultSearchTxt) {
            filterClause +=  ' AND Assignee.Name like \'%' + String.escapeSingleQuotes(usrSearchTxt) + '%\'';
        }
        if(filterBy == PROFILE_FILTER && filterId != ''){
            filterClause += ' AND Assignee.profileId = : filterId';
        } else if(filterBy == ROLE_FILTER && filterId != '') {
            filterClause += ' AND Assignee.UserRoleId = : filterId';
        } else if(filterBy == PGROUP_FILTER && filterId != '') {
            filterClause += ' AND AssigneeId IN (Select UserOrGroupId From GroupMember Where GroupId = : filterId)';
        } else if(filterBy == CGROUP_FILTER && filterId != '') {
            filterClause += ' AND AssigneeId IN (Select MemberId  From CollaborationGroupMember Where CollaborationGroupId  = : filterId)';
        } 
        queryString = queryString + ' Where ' +filterClause;
        psaList = (List<PermissionSetAssignment>)Database.query(queryString);           
    }
    
    /********************************************************************
     * Method to handle removing a Permission Set from all the user who
     * are currently assigned to that Permission Set
     ******************************************************************* */
    public void removePSAFromAll() {

        psaRemoveList = new List<PermissionSetAssignment>([SELECT Id, Assignee.Name, Assignee.Email, PermissionSet.Label
                                                           FROM PermissionSetAssignment
                                                           WHERE PermissionSetId =: recId]);

        ps = new List<PermissionSet>([SELECT Id, Name, Label
                                      FROM PermissionSet
                                      WHERE Id =: recId]);

        if(psaRemoveList == null || psaRemoveList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'The ' + ps[0].Label + ' Permission Set is not assigned to any users.'));
        }
        else {
            delete psaRemoveList;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'The ' + ps[0].Label + ' Permission Set has been successfully removed from ' + psaRemoveList.size() + ' users.'));
        }
    }
  
    public class record {
        public string recID {get; set;}
        public string recName {get; set;}
        public string recLabel {get; set;}
        
        public record() {}
        public record( string rid, string rname ) {
            recID = rid;
            recName = rname;
        }
    }
    
    private SelectOption[] getUserProfiles() {
        List<SelectOption> selectList = new List<SelectOption>();
        for(Profile uProfile : [Select ID, Name From Profile order by name asc limit :( isTest ? 5 : 500)]) {
            SelectOption option = new SelectOption(uProfile.ID, uProfile.Name);
            selectList.add(option);
        }
        return selectList;
     }
     private SelectOption[] getUserGroups() {
        List<SelectOption> selectList = new List<SelectOption>();
        for(Group uGroup : [SELECT Id, Name FROM Group WHERE Type='Regular' ORDER BY Name ASC LIMIT :( isTest ? 5 : 500 )]) {
            SelectOption option = new SelectOption(uGroup.ID, uGroup.Name);
            selectList.add(option);
        }
        return selectList;
     }
      private SelectOption[] getChatterGroups() {
        List<SelectOption> selectList = new List<SelectOption>();
        for(CollaborationGroup uGroup : [select id, name from CollaborationGroup order by name asc limit :( isTest ? 5 : 500)]) {
            SelectOption option = new SelectOption(uGroup.ID, uGroup.Name);
            selectList.add(option);
        }
        return selectList;
     }

     private SelectOption[] getUserRoles() {
        List<SelectOption> selectList = new List<SelectOption>();
        for(UserRole uRole : [Select ID, Name From UserRole WHERE portaltype = 'None' ORDER BY Name ASC LIMIT :( isTest ? 5 : 500)]) {
            SelectOption option = new SelectOption(uRole.ID, uRole.Name);
            selectList.add(option);
        }
        return selectList;
     }
     
     public void resetPSAList() {
         if(successCount == 0 && failedCount == 0) {
            return;
        }
        
        if(successCount > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, successCount + SUCCESS_MSG));
        } 
        
        if(failedCount > 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, failedCount + FAILURE_MSG));
        }
        this.showUsers();
     }
     
      public SelectOption[] getFilterByOptions() {
        List<SelectOption> selectList = new List<SelectOption>();
        selectList.add(new SelectOption('', '-None-'));
        selectList.add(new SelectOption(this.PROFILE_FILTER, 'Profile'));
        selectList.add(new SelectOption(this.ROLE_FILTER, 'Role'));
        selectList.add(new SelectOption(this.PGROUP_FILTER, 'Public Group'));
        selectList.add(new SelectOption(this.CGROUP_FILTER, 'Chatter Group'));
        return selectList;
     } 
     
      public SelectOption[] getFilterOptions() {
        List<SelectOption> selectList = new List<SelectOption>();
        SelectOption defaultOption = new SelectOption('', '-None-');
        selectList.add(defaultOption);
        if(filterBy == this.PROFILE_FILTER){
            selectList.addAll(this.getUserProfiles());
        } else if(filterBy == this.ROLE_FILTER) {
            selectList.addAll(this.getUserRoles());
        } else if(filterBy == this.PGROUP_FILTER) {
            selectList.addAll(this.getUserGroups());
        } else if(filterBy == this.CGROUP_FILTER) {
            selectList.addAll(this.getChatterGroups());
        }       
        return selectList;
     }

     public static testmethod void runTest() {
        RemovePermissionSetsController cs = new RemovePermissionSetsController();
        cs.resetSearch();
        cs.searchRecords();
        cs.getUserLicenses();
        cs.recId = cs.getUserLicenses().get(0).getValue();
        cs.obName = 'abc';
        cs.isTest = true;
        cs.obType = 'salesforce';
        cs.searchRecords();
        cs.showUsers();
        
        cs.resetSearch();
        CollaborationGroup chatterGroup = new CollaborationGroup();
        chatterGroup.name = 'testchattergroup';
        chatterGroup.CollaborationType  = 'Public';
        insert chatterGroup;
        
        Group grp = new Group();
        grp.name = 'testchattergroup';
        grp.type='Regular';
        insert grp;
                
        cs.getFilterByOptions();
        cs.filterBy = cs.PROFILE_FILTER;
        cs.getFilterOptions();
        cs.filterId = UserInfo.getProfileId();
        cs.usrSearchTxt = 'testuser';
        cs.showUsers(); 
        
        cs.filterBy = cs.ROLE_FILTER;
        cs.getFilterOptions();
        cs.usrSearchTxt = 'testuser';
        cs.filterId = UserInfo.getUserRoleId();
        cs.searchRecords(); 
        
        cs.filterBy = cs.PGROUP_FILTER;
        cs.getFilterOptions();
        cs.filterId = grp.id;
        cs.usrSearchTxt = 'testuser';
        cs.showUsers(); 
        
        cs.filterBy = cs.CGROUP_FILTER;
        cs.getFilterOptions();
        cs.usrSearchTxt = 'testuser';
        cs.filterId = chatterGroup.id;
        cs.showUsers();
        cs.successCount = 0;
        cs.failedCount = 0;
        cs.resetPSAList();
        cs.successCount = 1;
        cs.failedCount = 1;
        cs.resetPSAList();
        Record rec0 = new Record();
        Record  rec = new Record('testid','testname');
    }
}