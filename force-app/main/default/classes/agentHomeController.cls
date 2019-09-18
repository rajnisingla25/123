// (c) 2015 Appirio, Inc.
//
// Class Name: agentHomeController
// Description: Contoller Class for Task  List
//
// 25th May 2015    Ravindra Shekhawat   Original (Task # T-380827)
//
public with sharing class agentHomeController {

    private integer counter=0;  //keeps track of the offset
    private integer list_size=5; //sets the page size or number of rows
    public integer total_size; //used to show user the total size of the list
    public Integer pageNumber;
    public string selectedPage{get;set{selectedPage=value;}
    }
    public string taskIdToBeDeleted {get;set;}
       
    public SelectOption[] getTaskViews() {
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('My Tasks', 'My Tasks'));
    	return options;
    }
    
    public agentHomeController() {
        total_size = [SELECT count() FROM Task WHERE OwnerId =: UserInfo.getUserId()]; //set the total size in the constructor
        selectedPage='0';
    }
    
    public Task[] getTasks() {
                
        //if (selectedPage != '0') counter = list_size*integer.valueOf(selectedPage)-list_size;
        System.debug('Counter Is : '+counter);
        try { //we have to catch query exceptions in case the list is greater than 2000 rows
                Task[] taskList = [SELECT Id,Subject, WhatId, Status, Description, Priority, ActivityDate, WhoId, LastModifiedDate, LastModifiedById
                                     FROM Task WHERE OwnerId =: UserInfo.getUserId()
                                     order by Id
                                     limit :list_size
                                    offset :counter];                   
                return taskList;
        
        } catch (QueryException e) {                            
                ApexPages.addMessages(e);                   
                return null;
        }        
    }
    
    
    public PageReference First() { //user clicked a page number        
        system.debug('**** ' + selectedPage);
        counter = 0;
        System.debug('Counter Is First: '+counter);
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        selectedPage = '0';
         System.debug('Counter Is Previous mm: '+counter);
        counter =  counter - list_size;
        System.debug('Counter Is Previous: '+counter);
        return null;
    }

    public PageReference Next() { //user clicked next button
        selectedPage = '0';
        counter += list_size;
        System.debug('Counter Is Nexxt: '+counter);
        return null;
    }

    public PageReference End() { //user clicked end
        selectedPage = '0';
        counter = total_size - math.mod(total_size, list_size);
        System.debug('Counter Is End: '+counter);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }

    public Boolean getDisableNext() { //this will disable the next and end buttons
    	  System.debug('Counter Is : NNN'+counter+' List Size is :'+list_size + ' Total Size IS :'+total_size);
    	  System.debug('Disable Next: '+ (counter + list_size < total_size));
        if (counter + list_size < total_size) return false; else return true;
    }

    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        pageNumber =  counter/list_size + 1;
        return pageNumber;
    }

    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    
     // "Get" called when page rendered; "set" called by client-side Javascript
    public String selectedTab {
        get {
            if (selectedTab == null) {
                
                
                Last_Selected_Tab_On_AgentHome__c lastSelectedTab = Last_Selected_Tab_On_AgentHome__c.getInstance();
                if(lastSelectedTab != null && lastSelectedTab.Last_Selected_Tab__c != null){
                	selectedTab = lastSelectedTab.Last_Selected_Tab__c;
                }
                else{
                	// Select a default tab
                	selectedTab = 'vwAccTab';
                	lastSelectedTab.Last_Selected_Tab__c = selectedTab;
                	upsert lastSelectedTab;
                }
            }
            return selectedTab;
        }
        set {
            if (value != selectedTab) {
                 Last_Selected_Tab_On_AgentHome__c lastSelectedTab2 = Last_Selected_Tab_On_AgentHome__c.getInstance();
                 lastSelectedTab2.Last_Selected_Tab__c = value;
                 upsert lastSelectedTab2;
            }
            selectedTab = value;
            
        }
    }
    // Method for client-side Javascript to invoke; does nothing
    public PageReference selectTab() {
        return null;
    }
    
    public PageReference deleteTask() {
    	if(taskIdToBeDeleted != null){
    		delete [Select Id From Task WHERE Id =: taskIdToBeDeleted];
    	}
        return null;
    }
}