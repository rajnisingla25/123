// (c) 2015 Appirio, Inc.  
//
// Class Name: PublicGroupQueueManagementController
// Description: Allows for the administration of public groups without having the 'Manage User' profile permission.
//
// 2015-04-22   Mishaal Jamil    Deployed from Cloud Asset Library Original Task # T-380367
//
public with sharing class PublicGroupQueueManagementController {
	String QUEUE='Queue';
	String USERS='Users';
	String PARTNERUSERS='Partner Users';
	String PUBLICGROUPS='Public Groups';
	String REGULAR='Regular';



  public List<SelectOption> getGroupsToSearch() 
  {
    List<SelectOption> options = new List<SelectOption>();
    
    options.add(new SelectOption(USERS,USERS));          
    
/*
    try
    {   SObject s = Database.query('SELECT isPartner FROM user WHERE IsPartner = true limit 1'); 
        options.add(new SelectOption('PU','Partner Users'));
        options.add(new SelectOption('PR','Portal Roles'));
        options.add(new SelectOption('PRS','Portal Roles and Subordinates'));
        options.add(new SelectOption('RIP','Roles, Internal and Portal Subordinates'));
    }   
    catch(Exception e){ System.debug('No Partner Portal. '+e);}
*/
    options.add(new SelectOption(PUBLICGROUPS,PUBLICGROUPS));
//    options.add(new SelectOption('R','Roles'));
//    options.add(new SelectOption('RI','Roles and Internal Subordinates'));
    
/*    
    try 
    { 
        SObject s = Database.query('SELECT Id FROM Territory LIMIT 1'); 
        options.add(new SelectOption('T','Territories'));
        options.add(new SelectOption('TS','Territories and Subordinates'));
    }     
    catch(Exception e){ System.debug('No Territory Mgmt ' + e); }
*/    
    return options;   
  }
  
    //start dm 2014-12-17 fix collection exceeded.
    List<SelectOption> options2 = new List<SelectOption>();
    List<SelectOption> options3 = new List<SelectOption>();    

    //dm 2014-02-13 fix refetching of q's groups on save
    List<SelectOption> options = new List<SelectOption>();    

    public List<SelectOption> getOptions2() {
        return options2;
    }

    public List<SelectOption> getOptions3() {
        return options3;
    }    
    //end dm 2014-12-17  

  public List<SelectOption> getItems() 
  {
    if (options.size()==0)
    {
      options.add(new SelectOption('','--None--'));        
      options.add(new SelectOption('','--Groups--',true)); 
      Integer q=0;   
      Integer i=3; //dm 2014-12-17, count of groups & q's
      for(Group g:[SELECT 
                      Name,Id,type 
                      FROM Group 
                      WHERE type in (:REGULAR,:QUEUE) 
                      ORDER BY type desc,Name])
      {
       if(g.type==QUEUE && q==0)  
       {
           if(i<1000)//dm 2014-12-17
           {
             options.add(new SelectOption('','--Queues--',true)); 
           }
           else if(i<2000)
           {
             options2.add(new SelectOption('','--Queues--',true)); 
           }           
           else
           {
             options3.add(new SelectOption('','--Queues--',true)); 
           }           
           
           q++; 
       }    
       
       if(i<1000)
       {
         options.add(new SelectOption(g.Id,g.name));
       }
       else if(i<2000)
       {
         options2.add(new SelectOption(g.Id,g.name));
       }           
       else
       {
         options3.add(new SelectOption(g.Id,g.name));
       }           
       i++;
      } 
    }               
    return options;
  }   
  public String g {get;set;}
  public String SearchIn {
                              get{ 
                                  if (SearchIn==null) SearchIn=USERS;
                                  return SearchIn;
                              }
                              set;
                         }  
    
  public Map<Id, sObject> searchedUsers = new Map<Id, sObject>{};    
  Map<Id, sObject> allUsers = new Map<Id, sObject>{};    
  public String searchCriteria { get; set; }    
  public PageReference Search() 
  {
    Integer collectionLimit = 1000 - rightvalues.size();
    searchedUsers.clear();
     if(!searchCriteria.contains('%')) {
      searchCriteria = searchCriteria + '%';
     }
    if (SearchIn == USERS)
    {   

        searchedUsers = new Map<Id, User> ([
        SELECT Id, FirstName, LastName FROM User 
         WHERE 
          profile.userlicense.name = 'Salesforce' AND
           isactive = true AND 
           (name like :searchCriteria OR LastName like :searchCriteria OR FirstName like :searchCriteria) AND 
           id NOT in :rightvalues
            limit :collectionLimit ]);
    } 
    else if( SearchIn == PUBLICGROUPS)
    {
        searchedUsers = new Map<Id, sObject> ([
        Select Id, Name from Group 
         where 
          type='Regular' and
           name like :searchCriteria and 
           id not in :rightvalues
           and id != :g
            limit :collectionLimit ]);
    
    }           
    leftvalues.clear();
    leftvalues.addall(searchedUsers.keyset());
    allUsers.putAll(searchedUsers);

    return null;             
  }

  public PageReference getMembers()
  {
    originalUsers.clear();
    reset();
    getGroupMembers();
    if(SearchIn==USERS)
    {
        originalUsers = new Map<Id, sObject> ([SELECT Id, LastName, FirstName 
                                        FROM User 
                                        WHERE Id in :GroupMemberIds]);
    }
    else if(SearchIn==PUBLICGROUPS)
    {
        originalUsers = new Map<Id, sObject> ([SELECT Id, Name
                                        FROM Group 
                                        WHERE Id in :GroupMemberIds]);
    
    }                                    
    rightvalues.addAll(originalUsers.keyset());
    allUsers.putAll(originalUsers);    
    return null;
  }

  public Set<Id> GroupMemberIds = new Set<Id>();
  public void getGroupMembers()
  {
    List<groupmember>  gm = [SELECT Id,UserOrGroupId 
                                FROM GroupMember 
                                WHERE GroupId = :g];
    String tmp;
    for (GroupMember m: gm)
    {
      tmp = m.UserOrGroupId;
      if (tmp.substring(0,3) == '005')
      {
         GroupMemberIds.add(tmp);
      }
      else if (tmp.substring(0,3) == '00G')
      {
         GroupMemberIds.add(tmp);
      }      
      //add roles, territories
    }        
  }  

  public Map<Id,sObject> originalUsers = new Map<Id,sObject>{};
  public List<SelectOption> getSelectedValues()
  {
    return sortSelectOptions( rightValues );
  }    
  public PageReference removeClick() 
  {
     leftselected.clear();
     for(Id s : rightselected)
     {
          rightvalues.remove(s);
          leftvalues.add(s);
      }
     return null;
  }
  
  public PageReference addClick() 
  {
    rightselected.clear();
    for(Id s : leftselected)
    {
      leftvalues.remove(s);
      rightvalues.add(s);
    }
    return null;
  }

  public List<SelectOption> getunSelectedValues()
  {
    return sortSelectOptions ( leftvalues );
  }   

  //Constructor
  public PublicGroupQueueManagementController() {
  }    
   
  public List<SelectOption> sortSelectOptions(Set<Id> workingSet)
  {
    List<String> tmpList = new List<String>{};
    for (Id i: workingSet)
    {
//      tmpList.add(allUsers.get(i).LastName +':'+ i);
        if(SearchIn==USERS) tmpList.add(allUsers.get(i).get('LastName') +':'+ i);
        else if(SearchIn==PUBLICGROUPS) tmpList.add(allUsers.get(i).get('Name') +':'+ i);

    }
    tmpList.sort();
    List<SelectOption> options = new List<SelectOption>();        
    Id tmpId;
    for(String s: tmpList)
        {
          tmpId = s.split(':')[1];
    //      options.add(new SelectOption(tmpId, allUsers.get(tmpId).FirstName +' '+ allUsers.get(tmpId).LastName ));   
        if(SearchIn==USERS)
        {
            //options.add(new SelectOption(tmpId, allUsers.get(tmpId).get('FirstName') +' '+ allUsers.get(tmpId).get('LastName') ));   
            options.add(new SelectOption(tmpId, allUsers.get(tmpId).get('LastName') +' '+ allUsers.get(tmpId).get('FirstName') ));    
        }
        else if(SearchIn==PUBLICGROUPS)
        {  
            options.add(new SelectOption(tmpId, String.Valueof(allUsers.get(tmpId).get('Name'))));         
        }        
    }
    return options;
  }   

  Public List<Id> leftselected{get;set;}
  Public List<Id> rightselected{get;set;}
  public Set<Id> leftvalues = new Set<Id>();
  public Set<Id> rightvalues = new Set<Id>();    
  
  public PageReference Save() 
  {
    List<GroupMember> addGroupMember = new List<GroupMember>{};
    List<GroupMember> removeGroupMember= new List<GroupMember>{};    
    List<Id> removeUsers = new List<Id>{};    
    
    GroupMember tmpGroupMember;
      for(Id r: rightvalues)
      {
        if (!originalUsers.containsKey(r))
        {
           tmpGroupMember = new GroupMember(GroupId = g, UserOrGroupId = r);
           addGroupMember.add(tmpGroupMember);            
        }
      }
        
      for( Id o: originalUsers.keySet())
      {
        if(!rightvalues.contains(o))
        {
          removeUsers.add(o);   
        }
      }
      if (removeUsers.size() > 0)
      {
        removeGroupMember = [SELECT Id 
                                FROM GroupMember 
                                WHERE GroupId = :g and UserOrGroupId in :removeUsers];
      }
      try 
      {
        if (addGroupMember.size() > 0)
        {
          insert(addGroupMember); 
        }
        if (removeUsers.size() >0)
        {
          delete(removeGroupMember);
        }
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Your Changes has been saved Successfully!'));
      }
      catch (Exception e) 
      {
        ApexPages.addMessages(e);
      }
      return null;
    }    
    
    public PageReference GoHome() 
    {
      return new PageReference('/home/home.jsp');
    }    

    public void reset() 
    { 
      GroupMemberIds.clear();
      searchCriteria='';
      leftvalues.clear();
      rightvalues.clear();
      //rightvalues.addAll(originalUsers.keyset());
      searchedUsers.clear();
      allUsers.clear();
      getItems();
      allUsers.putAll(originalUsers);
    }
}