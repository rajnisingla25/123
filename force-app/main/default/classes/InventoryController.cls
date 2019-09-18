global class InventoryController {


/************** Created by Arun Sharma **************************************
********   For Move Inc Leapfrog Project ************************************
*****************  Inventory Controller *****************************
********* Created on April 2015 ********************************************* 
********** Program calls Wailtist wbservice , returns JSON back to VF WL page****/



private final Account acct;
public List<Invlist> WLs;

public List<Invlist> MyInvSetList;

public string Sendjson {get; set;}
private String mParty_Id;
public string mPhone    {get; set;}
public string MyUserid{get;set;}
public string MyUserName{get;set;}
public string MyUserName1{get;set;}
public string MyUserEmail{get;set;}
public string MyUserProfileName {get;set;}
public string MyUserProfileManagerId {get;set;}
public string MyUserProfileId {get;set;}
public string MyUserLocale {get;set;}
public string MyUserTimezone {get;set;}
public string MyUserFullName{get;set;}
public integer intWhichPageisCalling = 1; // 1 is Account Waitlist ,2 is My Wailist , 3 is My Team View , 4 is Top10 

public string mReservationId {get;set;}
public string mMyMethod {get;set;}


 public string MyTransactionId {get;set;}
  public string MyLineItemId {get;set;}
   public string MyProductName {get;set;}
    public string MyProductType {get;set;}
     public string MyProductSize {get;set;}
     public string MyInventoryPool {get;set;}
      public string MyMarketName {get;set;}
      public string MyPartyId {get;set;}
      public string MyLeadType {get;set;}
      public string MyMarketState {get;set;}
     public string MyReservedQty {get;set;}
      public string MyMarketId {get;set;}
      public string MyLockReleaseDate {get;set;}
      public string MyInventorystatus {get;set;}
       public string MyCreatedDate {get;set;}
       public string MyUpdatedDate {get;set;}
        public string MyReservedBy {get;set;}

     
     
      public void setMyInvList(List<Invlist> newvalue)
      {
     
     
       MyInvSetList = newvalue;
     
     
      }



        public void setPhone(String newvalue) 
        
        { 
            
            // do nothing 
            
            mPhone = newvalue;
            System.debug('Hello');
            //return mToken;
            
        }
        
        public string getPhone()
        
        { 
            
            // do nothing 
            
            return mPhone ;
            
            
        } 


        public void setReservation(String newvalue) 
        
        { 
            
            // do nothing 
            
            mReservationId = newvalue;
            System.debug('Hello');
            //return mToken;
            
        }
        
        public string getReservation()
        
        { 
            
            // do nothing 
            
            return  mReservationId ;
            
            
        } 

    public void setMyMethod(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyMethod = newvalue;
            System.debug('Hello');
            //return mToken;
            
        }
        
        public string getMyMethod()
        
        { 
            
            // do nothing 
            
            return  mMyMethod ;
            
            
        } 



 


public InventoryController(ApexPages.StandardController stdController) {
/*Account acct_temp;
string MYId  ;

            this.acct = (Account)stdController.getRecord();
            
            System.debug('Data Controller Called');
            mMyMethod  ='Put';
            

try
{
    MYID = acct.id ;
    
    if (MYID != null)
    {
    acct_temp = [SELECT Id, Name, Site ,Party_ID__c,Phone FROM Account
                                WHERE Id = :ApexPages.currentPage().getParameters().get('id')];

                
            mParty_Id = acct_temp.Party_ID__c;
                   
          
            
    }     

//     StoreMainParameters();

}
catch (exception e)
{
    
    StoreMainParameters();
     System.debug('An exception occurred: ' + e.getMessage());
     
     try
     {
     mPhone = acct.Phone;
     }
     catch(exception e1)
     {
     // do nothing 
        
     }
     
     
     
}*/

            
            
}




public InventoryController()
{





}
 

public void StoreMainParameters( )
{

                try
                {
                
                MyUserid = Userinfo.getUserId();
                MyUserName = Userinfo.getusername();
                MyUserEmail= Userinfo.getuseremail();
                MyUserName1 =  Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
                MyUserFullName = Userinfo.getName();
                MyUserProfileId  = Userinfo.getProfileId();
                MyUserLocale= Userinfo.getLocale();
            //  MyUserTimezone = Userinfo.getTimeZone();
                
                 Profile p = [select name  from Profile where id = :UserInfo.getProfileId()];
                
            //  MyUserProfileManagerId = p.ManagerId;
                MyUserProfileName = p.name ;
                
                
                    
                System.debug('mParty_Id '+ mParty_Id );
                
                
                if (mParty_Id !=null)
                {
                  intWhichPageisCalling = 1 ; 
                  
                               mMYFilter = 'party_id =' + mParty_Id ;
                                
                              
                }
                else { // No account Id exists , assume My Waitlist 
                    intWhichPageisCalling = 2 ;
                    
                     mMYFilter = 'Owner_name =' +  MyUserName ;
                     MyUserName = 'hriggio';
                     
                     // overriding owner name for testing Arun
                     
                      mMYFilter = 'Owner_name =' +  MyUserName ;
                    
                     System.debug(mMYFilter);
                
                      }
                      
System.debug(mMYFilter);


      
                
                
                
                
                }  
                catch (exception e)
                {   
                
                System.debug('error occured in setting user profile data' + e.getMessage());  
                
                }
    
}
    
    
    public List<Invlist> accountwaitlist
    {
        
        get
        {
                        if (accountwaitlist == null)
                    {
                    try
                    {   
                     List<Invlist> WLs ;
                    
                     
                     
                     
                //      accountwaitlist = getAccountWLs(WLs ,orderbys);
                    
                      try
     {       
        integer lock_party_id = 1245;
       string mydate = '2015-07-18T01:13:28.0000000+00:00';
       Date lock_release_date =Date.valueOf(mydate);
       String transaction_id = '106168';
       String ReservationID = '160';
       string operation ;
       string message1 ;

    //OracleComServicebusapplicationL.lockInventoryQSPort stub= new OracleComServicebusapplicationL.lockInventoryQSPort();
    
    
   
    
       
  /*
   <transaction_id xmlns="">106165</transaction_id>
            <line_item_id xmlns="">1</line_item_id>
            <product_name xmlns="">Connection for Co-Brokerage</product_name>
            <product_type xmlns="">Postal Code</product_type>
            <product_size xmlns="">Full</product_size>
            <inventory_pool xmlns="">available</inventory_pool>
            <lead_type xmlns="">Flex</lead_type>
            <market_name xmlns="">00006</market_name>
            <market_state_id xmlns="">CA</market_state_id>
            <request_quantity xmlns="">1</request_quantity>
            <market_id xmlns="">6973</market_id>
  
  
  */
   system.debug('*****Lock Inventory status Before Reservation Item Init*****');
    
    // Removed word xmlns because of big length , start with Oracle
    //    OracleComServicebusapplicationL.reservation_line_items_element reservation_line_items = new     OracleComServicebusapplicationL.reservation_line_items_element();
        
      //  OracleComServicebusapplicationL.reservation_line_item_element[] reservation_line_item = new    OracleComServicebusapplicationL.reservation_line_item_element[]{};
      
      system.debug('*****Lock Inventory status Init*****');
    
       //  OracleComServicebusapplicationL.reservation_line_item_element  tmp_reservation_line_item = new OracleComServicebusapplicationL.reservation_line_item_element();
    
/*     tmp_reservation_line_item.line_item = '1';
        tmp_reservation_line_item.market_id = '6973';
        tmp_reservation_line_item.market_name = '00006';
        tmp_reservation_line_item.product_name ='Connection for Co-Brokerage';
        tmp_reservation_line_item.product_type ='Postal Code';
          tmp_reservation_line_item.lead_type = 'Flex';
            tmp_reservation_line_item.requested_quantity  =1;
          
        reservation_line_item.add(tmp_reservation_line_item);
       
               system.debug('*****Lock Inventory status Init All First Init*****');
  
       
       
        system.debug('*****Lock Inventory status Init All variable Init*****');
        reservation_line_items.reservation_line_item =   reservation_line_item;
        
       
    system.debug('*****Lock Inventory status Before Call*****');
    

    OracleComServicebusapplicationL.reservationtype  result = stub.lockInventory( operation, lock_release_date, lock_party_id,
     transaction_id,ReservationID, reservation_line_items);
     
   //  lockInventory(String operation,Date lock_release_date,Integer party_id,String transaction_id,String ReservationID,
    // OracleComServicebusapplicationL.reservation_line_items_element reservation_line_items)
    
     
    system.debug('*****Lock Inventory status After Call*****'+ result);*/
    
      
     }
     
     catch (Exception e)
     
     {
      System.debug('An exception occurred during Web Service Call  Lock Inventory: ' + e.getMessage());

        
     } 
                    
                    
                    
                    
                    accountwaitlist =  GetWaitlistfromWebService() ;
                      System.debug('Inventory List  array'+ accountwaitlist );
                    
                    
                    if (accountwaitlist == null)
                    {
                      System.debug('accountwaitlist Arun SOA FAILED . fetching temp array' );
                    
      //                accountwaitlist = getAccountWLs(WLs ,orderbys);
                    
                    }
                    
                    System.debug('accountwaitlist Arun ' + accountwaitlist);
                    }
                    catch (exception e ) 
                    {
                    
                         System.debug('An exception occurred: ' + e.getMessage());
                       
                        // do nothing now , will add 
                             String[] orderBys = new String[] {'token asc'};
                       }
                                    
                    
                    }   
        return accountwaitlist;
        }
        
        set;
        
    }
    
    
        
        private string mInputValue;
        private string mToken;
        private  string mMarket ='94010';
        private  string mMarkettype='Postal Code' ;
    //  private  string mAccountId ='12345';
       private  string mAccountId  ;
        private  string mStatus ;
        private  string mDegree ;
        private  string mLeadroutingtype ;
        private  string mSlotsize ;
        private  string mMarketspend ;
        private  string mJson ;
        private string mnotes ;
        private string mqtyinterested;
        private string moperation;
        private string mMyOrderBy ='OrderBy=LockReleaseDate';
        private string mMyFilter ='';
        private string mMyLimit = 'Take=10';
        private string mMyPageNo = 'Skip=0';
        private string mMyPool = 'GetPendingAllocation';
        
        private string mWaitlistStatus ='GetPendingAllocation';
        private string mFilterType='Inventory Pool';      
        private string mAccountName ;
        private string mInputType ;
        
        public void setToken(String newvalue) 
        
        { 
            
            // do nothing 
            
            mToken = newvalue;
            System.debug('Hello');
            //return mToken;
            
        }
        
        public string getToken()
        
        { 
            
            // do nothing 
            
            return mToken ;
            
            
        } 
        
            
        public void setDegree(String newvalue) 
        
        { 
            
            // do nothing 
            
            mDegree = newvalue;
            System.debug('Hello');
            
            
        }
        
        public string getDegree()
        
        { 
            
            // do nothing 
            
            return mDegree ;
            
            
        }
        
        
            
        public void setSlotSize(String newvalue) 
        
        { 
            
            // do nothing 
            
            mSlotSize = newvalue;
            System.debug('Hello');
            
        }
        
        public string getSlotSize()
        
        { 
            
            // do nothing 
            
            return mSlotSize ;
            
            
        } 
        
         
            
        public void setLeadRoutingType(String newvalue) 
        
        { 
            
            // do nothing 
            
            mLeadRoutingType = newvalue;
            System.debug('Hello');
            
        }
        
        public string getLeadRoutingType()
        
        { 
            
            // do nothing 
            
            return mLeadRoutingType ;
            
            
        } 
        
        
    
        public void setStatus(String newvalue) 
        
        { 
            
            // do nothing 
            
            mStatus = newvalue;
            System.debug('Hello');
            
        }
        
        public string getStatus()
        
        { 
            
            // do nothing 
            
            return mStatus ;
            
            
        }       
        
                public void setJson(String newvalue) 
        
        { 
            
            // do nothing 
            
            mJson = newvalue;
            System.debug('Hello');
            
        }
        
        public string getJson()
        
        { 
            
            // do nothing 
            
            return mJson ;
            
            
        } 
        
                public void setAccountId(String newvalue) 
        
        { 
            
            // do nothing 
            
            mAccountId = newvalue;
            System.debug('Hello Setting Account Id ' + newvalue);
            System.debug('Hello Setting Party Id ' + mParty_Id);
            
        }
        
        public string getAccountId()
        
        { 
            
            // do nothing 
            
            return mAccountId ;
            
            
        } 
        
        
        public void setNotes(String newvalue) 
        
        { 
            
            // do nothing 
            
            mNotes = newvalue;
            

            
        }
        
        public string getNotes()
        
        { 
            
            // do nothing 
            
            return mNotes ;
            
            
        } 
        
        
        
        
        public void setqtyinterested(String newvalue) 
        
        { 
            
            // do nothing 
            
            mqtyinterested = newvalue;
            

            
        }
        
        public string getqtyinterested()
        
        { 
            
            // do nothing 
            
            return mqtyinterested ;
            
            
        } 
        
        
        
        public void setoperation(String newvalue) 
        
        { 
            
            // do nothing 
            
            moperation = newvalue;
            

            
        }
        
        public string getoperation()
        
        { 
            
            // do nothing 
            
            return moperation;
            
            
        }   
        
        
        public string getMyOrderBy()
        
        { 
            
            // do nothing 
            
            return mMyOrderBy;
            
            
        } 
        
        
            
        public void setMyOrderBy(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyOrderBy = newvalue;
            

            
        }
        
            public string getMyFilter()
        
        { 
            
            // do nothing 
            
            return mMyFilter;
            
            
        } 
        
        
            
        public void setMyFilter(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyFilter = newvalue;
            

            
        }
        
        public string getMyLimit()
        
        { 
            
            // do nothing 
            
            return mMyLimit;
            
            
        } 
        
        
            
        public void setMyLimit(String newvalue) 
        
        { 
            
            // do nothing 
            
            mMyLimit = newvalue;
            System.debug(mMyLimit);

            
        }
        
        public String getWaitlistStatus() {

        return mWaitlistStatus;

    }
    
        public String getAccountName() {

                  return mAccountName;

             }
    

  

    public void setWaitlistStatus(String WaitlistStatus) {
        
        
          
      
        
        if (WaitlistStatus!=null)
        {
        
        
        
    //  WaitlistStatus = EncodingUtil.urlEncode(WaitlistStatus ,'UTF-8');

   
        this.mWaitlistStatus = WaitlistStatus.replace(' ', '%20');
        
        
        System.debug('Compare' + 'Inventory Available Flex'.equals(mFilterType)) ;
        System.debug('Compare 50' + 'Greater than 50 '.equals(WaitlistStatus) + WaitlistStatus); 
    
      
      System.debug('mMyFilter in Set is ' +mMyFilter);
        mMyFilter ='';
         
         if (WaitlistStatus !=null)
         {
          
      System.debug('mParty_Id ' + mParty_Id );
                     if  (mParty_Id != null)
                     {
                        mMyFilter = 'party_id=' + mParty_Id   ;
                     }   
                     else
                     {
                 //     mMyFilter = 'Owner_name=' + MyUserName   ;
                        
                     }   
                        
                     
      
            if ('Waitlist Status'.equals(mFilterType)) 
            {
     
               
     
     
                mMyFilter = mMyFilter + '&waitlist_status=' + mWaitlistStatus + '&waitlist_type=Hot' ;
         
       //    mMyFilter = mMyFilter + '&waitlist_type=Hot' ;
         
            }else if  ('Waitlist Type'.equals(mFilterType)) 
               {
         
             
     
                mMyFilter = mMyFilter  + '&waitlist_type=' + mWaitlistStatus ;
         
                   
               }else if  ('Inventory Available Flex'.equals(mFilterType)) 
               {
                            if ('Greater than Zero'.equals(WaitlistStatus) )
                    {
                         //   mMyFilter = mMyFilter  +  '&invtotalavailableflex' + '>=' + 1 ; // encoding with %3E%3D
                           mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '0' ; 
                     
                    }else if   ('Greater than 1'.equals(WaitlistStatus) )
                    {
                        mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '1' ; 
                    
                  //     mMyFilter = mMyFilter  +  '&Inventory_available_flex'+ '%3C%3D' + 0 ;       
                   
                    }
                    else if   ('Greater than 5'.equals(WaitlistStatus) )  
                    {
                         mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '5' ; 
                   
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    } else if   ('Greater than 10'.equals(WaitlistStatus) )  
                    {
                    //  mMyFilter = mMyFilter  +   '&inventory_available_flex' + '%GreaterThanOrEqualTo%' + 10 ;
                      
                          mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '10' ; 
                  
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 50'.equals(WaitlistStatus) )  
                    {
                  //    mMyFilter = mMyFilter  +   '&Inventory_available_flex' + 'GreaterThanOrEqualTo' + 50 ;
                       mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '50' ; 
                  
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 25'.equals(WaitlistStatus) )  
                    {
                        mMyFilter = mMyFilter  +   '&%3EInventory_available_flex=' + '25' ; 
                   
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                    
                    
               
               }
               else if  (mFilterType == 'Inventory Available Fast') 
               {
                
                      if ('Greater than Zero'.equals(WaitlistStatus) )
                    {
                         //   mMyFilter = mMyFilter  +  '&invtotalavailableflex' + '>=' + 1 ; // encoding with %3E%3D
                            mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '0' ;
                            
                                          
                            
                    }else if   ('Greater than 1'.equals(WaitlistStatus) )
                    {
                                         mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '1' ;
          
                  //     mMyFilter = mMyFilter  +  '&Inventory_available_fast'+ '%3C%3D' + 0 ;       
                   
                    }
                    else if   ('Greater than 5'.equals(WaitlistStatus) )  
                    {
                                          mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '5' ;
         
                  //     mMyFilter = mMyFilter  +  '&invtotalavailablefast'+ '%3C%3D' + 0 ;       
                   
                    } else if   ('Greater than 10'.equals(WaitlistStatus) )  
                    {
                                        mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '10' ;
           
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 50'.equals(WaitlistStatus) )  
                    {
                                        mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '50' ;
           
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 25'.equals(WaitlistStatus) )  
                    {
                       mMyFilter = mMyFilter  + '&%3EInventory_available_fast=' + '25' ;
             
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
               }
               else if  (mFilterType == 'Presales Available Fast') 
               {
               
                                                if ('Greater than Zero'.equals(WaitlistStatus) )
                    {
                         //   mMyFilter = mMyFilter  +  '&presalesavailablefast' + '>=' + 1 ; // encoding with %3E%3D
                            mMyFilter = mMyFilter  +  '&presalestotalavailablefast' + '%GreaterThanOrEqualTo%' + 0 ;
                            
                    }else if   ('Greater than 1'.equals(WaitlistStatus) )
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 1 ;
                      
                  //     mMyFilter = mMyFilter  +  '&Inventory_available_flex'+ '%3C%3D' + 0 ;       
                   
                    }
                    else if   ('Greater than 5'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&Inventory_available_fast' + '%GreaterThanOrEqualTo%' + 5 ;
                      
                  //     mMyFilter = mMyFilter  +  '&presalestotalavailablefast' + '%3C%3D' + 0 ;       
                   
                    } else if   ('Greater than 10'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 10 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailablefast'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 50'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 50 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 25'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 25 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailablefast'+ '%3C%3D' + 0 ;       
                   
                    }  
               
               
               }
               else if  (mFilterType == 'Presales Available Flex') 
               {
                   
                                             if ('Greater than Zero'.equals(WaitlistStatus) )
                    {
                         //   mMyFilter = mMyFilter  +  '&invtotalavailableflex' + '>=' + 1 ; // encoding with %3E%3D
                            mMyFilter = mMyFilter  + '&presalestotalavailableflex'  + '%GreaterThanOrEqualTo%' + 0 ;
                            
                    }else if   ('Greater than 1'.equals(WaitlistStatus) )
                    {
                      mMyFilter = mMyFilter  +   '&Inventory_available_flex' + '%GreaterThanOrEqualTo%' + 1 ;
                      
                  //     mMyFilter = mMyFilter  +  '&presalestotalavailablefast' + '%3C%3D' + 0 ;       
                   
                    }
                    else if   ('Greater than 5'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 5 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    } else if   ('Greater than 10'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 10 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 50'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 50 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
                     else if   ('Greater than 25'.equals(WaitlistStatus) )  
                    {
                      mMyFilter = mMyFilter  +   '&presalestotalavailablefast'  + '%GreaterThanOrEqualTo%' + 25 ;
                      
                  //     mMyFilter = mMyFilter  +  '&invtotalavailableflex'+ '%3C%3D' + 0 ;       
                   
                    }
               
               
               }
               
                else if  (mFilterType == 'Product') 
               {
                        
                      
                        
                        WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                   //     WaitlistStatus = EncodingUtil.urlEncode(WaitlistStatus ,'UTF-8');
                         WaitlistStatus = WaitlistStatus.replace('-', '%2D');
                   
                        mMyFilter = mMyFilter  +  '&Product_type=' + WaitlistStatus ;
                           
               
               }
                else if  (mFilterType == 'Assigned AE') 
               {
                        
                      
                        
                    //  WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                       mMyFilter = mMyFilter  +  '&Owner_name=' + WaitlistStatus ;
                
                        
                        
                        
                        
               
               }
                 else if  (mFilterType == 'Input AE') 
               {
                        
                      
                        
                    //  WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                        mMyFilter = mMyFilter  +  '&Created_by=' + WaitlistStatus ;
                        
               
               }
                else if  (mFilterType == 'No of Records') 
               {
                        
                      
                        
                    //  WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                       mMyLimit = 'Take=' + WaitlistStatus ;
                        
               
               }else if  (mFilterType == 'Inventory Pool') 
               {
                        
                      
                        
                    //  WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                       mMyPool = WaitlistStatus ;
                        
               
               }else if  (mFilterType == 'Page No') 
               {
                        
                      
                        
                    //  WaitlistStatus = WaitlistStatus.replace(' ', '%20');
                       mMyPageNo = WaitlistStatus ;
                       
                       mMyPageNo = 'Skip=' + WaitlistStatus ;
                        
               
               }
               
               
               
               
               else
               {
                
                
                            //  mMyFilter = '' ;
               }
         
         }
         
                   
        System.debug('MyFilter SetWaitlist Item is = ' +  mMyFilter);
        }
       

    }
    
    
    public pageReference makeSOACallforGet()
    {
        
        
        System.debug('makeSOACallforGet Called : My Filter is ' + mMyFilter  + 'mMyFilter' + mWaitlistStatus);
        
               try
                {
                accountwaitlist =  GetWaitlistfromWebService() ;
                    System.debug('accountwaitlist Arun ' + accountwaitlist);
                    
                    this.accountwaitlist = accountwaitlist;
                
                }   
                    
                    catch (exception e ) 
                    {
                        // do nothing now , will add 
                         System.debug('An exception occurred: ' + e.getMessage());
                        
                    
                    }
        
        
        return null;
        
    }
    
   
        
        
    public List<SelectOption> getWaitlistStatusItems() {

        List<SelectOption> options = new List<SelectOption>();

       options.add(new SelectOption('',''));
       
       System.debug('mFilterType' + mFilterType);
      
        if (mFilterType!='') 
        {
      
                         
                         
                         
                if ('Waitlist Status'.equals(mFilterType)) {
                
                        options.add(new SelectOption('Pending Configuration','Pending Configuration'));
                        options.add(new SelectOption('Pending Pre-Auth','Pending Pre-Auth'));
                        options.add(new SelectOption('Pending Inventory','Pending Inventory'));
                        options.add(new SelectOption('Fulfilled','Fulfilled'));
                        
                } else if  ('Waitlist Type'.equals(mFilterType )) {
                        options.add(new SelectOption('Hot','Hot'));
                        options.add(new SelectOption('Warm','Warm'));
                } else if  ('Inventory Available Flex'.equals(mFilterType))  {
                        options.add(new SelectOption('Greater than Zero','Greater than Zero'));
                        options.add(new SelectOption('Greater than 1','Greater than 1'));
                        options.add(new SelectOption('Greater than 5','Greater than 5'));
                        options.add(new SelectOption('Greater than 10','Greater than 10'));
                        options.add(new SelectOption('Greater than 25','Greater than 25'));
                        options.add(new SelectOption('Greater than 50','Greater than 50'));
                        
                        
                } else if  ('Inventory Available Fast'.equals(mFilterType))  {
                            options.add(new SelectOption('Greater than Zero','Greater than Zero'));
                        options.add(new SelectOption('Greater than 1','Greater than 1'));
                        options.add(new SelectOption('Greater than 5','Greater than 5'));
                        options.add(new SelectOption('Greater than 10','Greater than 10'));
                         options.add(new SelectOption('Greater than 25','Greater than 25'));
                        options.add(new SelectOption('Greater than 50','Greater than 50'));
                   
                        
                }else if  ('Presales Available Flex'.equals(mFilterType))  {
                        options.add(new SelectOption('Greater than Zero','Greater than Zero'));
                        options.add(new SelectOption('Greater than 1','Greater than 1'));
                        options.add(new SelectOption('Greater than 5','Greater than 5'));
                        options.add(new SelectOption('Greater than 10','Greater than 10'));
                        options.add(new SelectOption('Greater than 25','Greater than 25'));
                        options.add(new SelectOption('Greater than 50','Greater than 50'));
                   
                        
                } else if  ('Presales Available Fast'.equals(mFilterType))   {
                        options.add(new SelectOption('Greater than Zero','Greater than Zero'));
                        options.add(new SelectOption('Greater than 1','Greater than 1'));
                        options.add(new SelectOption('Greater than 5','Greater than 5'));
                        options.add(new SelectOption('Greater than 10','Greater than 10'));
                        options.add(new SelectOption('Greater than 25','Greater than 25'));
                        options.add(new SelectOption('Greater than 50','Greater than 50'));
                   
                 
                        
                        
                }else if  ('Product'.equals(mFilterType))   {
                        options.add(new SelectOption('Connection for Co-Brokerage','Connection for Co-Brokerage'));
                        options.add(new SelectOption('Feature Home','Feature Home'));
                        options.add(new SelectOption('FAC','FAC'));
                        options.add(new SelectOption('DAP','DAP'));
                        options.add(new SelectOption('Tigerlead','Tigerlead'));
                        
                        
                }else if  ('Assigned AE'.equals(mFilterType))   {
                        options.add(new SelectOption('hriggio','hriggio'));
                        options.add(new SelectOption('qdinh','qdinh'));
                        options.add(new SelectOption('blippold','blippold'));
                        options.add(new SelectOption('runassigned','runassigned'));
                        options.add(new SelectOption('jmcgough','jmcgough'));
                        options.add(new SelectOption('khastings','khastings'));
                        
                        
                        
                }else if  ('Input AE'.equals(mFilterType))   {
                        options.add(new SelectOption('hriggio','hriggio'));
                        options.add(new SelectOption('qdinh','qdinh'));
                        options.add(new SelectOption('blippold','blippold'));
                        options.add(new SelectOption('runassigned','runassigned'));
                        options.add(new SelectOption('jmcgough','jmcgough'));
                        options.add(new SelectOption('khastings','khastings'));
                        
                        
                        
                }else if  ('No of Records'.equals(mFilterType))   {
                        options.add(new SelectOption('10','10'));
                        options.add(new SelectOption('25','25'));
                         options.add(new SelectOption('50','50'));
                        options.add(new SelectOption('100','100'));
                        options.add(new SelectOption('500','500'));
                        options.add(new SelectOption('1000','1000'));
                       
                        
                        
                }
                 else if  ('Inventory Pool'.equals(mFilterType )) {
                        options.add(new SelectOption('GetAllReservations','GetAllReservations'));
                        options.add(new SelectOption('GetPendingAllocation','GetPendingAllocation'));
                        options.add(new SelectOption('GetSalesEventPool','GetSalesEventPool'));
                }
                else if  ('Page No'.equals(mFilterType )) {
                        options.add(new SelectOption('1','1'));
                        options.add(new SelectOption('2','2'));
                        options.add(new SelectOption('3','3' ));
                        options.add(new SelectOption('3','3' ));
                        options.add(new SelectOption('5','5' ));
                        options.add(new SelectOption('6','6' ));
                        options.add(new SelectOption('7','7' ));
                        options.add(new SelectOption('8','8' ));
                        options.add(new SelectOption('9','9' ));
                        options.add(new SelectOption('10','10' ));
                }
                
                
                      
      
      
      
         }

 
        return options;

    }
        
  public List<SelectOption> getFilterList() {

        List<SelectOption> options = new List<SelectOption>();

       
           options.add(new SelectOption('Inventory Pool','Inventory Pool'));
           options.add(new SelectOption('',''));
           
     //   options.add(new SelectOption('Product','Product'));
     //   options.add(new SelectOption('Party Id','Party Id'));
      //  options.add(new SelectOption('No of Records','No of Records'));
      //   options.add(new SelectOption('Page No','Page No'));
        

 
        return options;

    }
    
    public String getFilterType() {

        return mFilterType;

    }

     

    public void setFilterType(String filtertype) {

        this.mFilterType = filtertype;

    }
    
    
    
      public List<SelectOption> getInputList() {

        List<SelectOption> options = new List<SelectOption>();

       
        options.add(new SelectOption('',''));
     //   options.add(new SelectOption('Assigned AE','Assigned AE'));
     //   options.add(new SelectOption('Input AE','Input AE'));
     //   options.add(new SelectOption('Party Id','Party Id'));
      //  options.add(new SelectOption('No of Records','No of Records'));
      //  options.add(new SelectOption('Token','Token'));
        

 
        return options;

    }
    
    
    public String getInputType() {

        return mInputType;

    }

     

    public void setInputType(String newvalue) {

        this.mInputType = newvalue;
        
        
        
        
        
        

    }
    
      public void setInputValue(String newvalue) {

        this.mInputValue = newvalue;
        
        
        
        
        
        

    }
    
        

        
public String getInputValue() {

        return mInputValue;

    }

     
       
    
    
    
     public pageReference submit()
    {
        
        System.debug('Submit Call');
          System.debug('Reached Submit Function' + 'Sendjson' + Sendjson);  
      //  GenerateAjax(Sendjson);
        return null;
    }
    
    public pageReference SetPageSize()
    {
        
        mMyLimit = 'Take=10';        
        return null;
    }
    
      


public class Invlist 
{
    public string reservation_id {get;set;}
    public string party_id { get; set; }
    public string product_type { get; set; }
    public string market_type { get; set; }
    public string transaction_id { get; set; }
    public string line_item_id { get; set; }
    public string product_name { get; set; }
    public string product_size { get; set; }
    public string inventory_pool { get; set; }
    public string lead_type { get; set; }
    public string market_name { get; set; }
    public string market_state_id { get; set; }
    public string reserved_quantity { get; set; }
    public string lock_release_date { get; set; }
    public string   market_id { get; set; }
    public string inventory_status { get; set;} 
    public string created_date  { get; set;}
    public string UpdatedDate { get; set;}
   
   
   
    
     public Invlist()
     {}
    
    public Invlist(
    string reservation_id, 
    string transaction_id ,
    string  line_item_id ,
    string  product_name ,
    string product_type ,
    string product_size ,
    string inventory_pool ,
    string    lead_type ,
    string   market_name ,
    string  market_state_id ,
    string reserved_quantity ,
    string   market_id ,
    string   party_id,
   string     lock_release_date ,
   string inventory_status , 
   string created_date  ,
   string UpdatedDate 
   
    
    )
    {
    this.reservation_id =  reservation_id;   
    this.transaction_id= transaction_id ;
    this.party_id =party_id ;
    this.product_type =   product_type;
    this.market_name = market_name;
    this.line_item_id =line_item_id;
    this.product_name = product_name;
    this.product_size =product_size;
    this.inventory_pool = inventory_pool;
    this.lead_type =lead_type ;
    this.market_state_id   =market_state_id   ;
    this.reserved_quantity =reserved_quantity ;
    this.market_id =market_id ;
    this.lock_release_date =lock_release_date;
    this.inventory_status = inventory_status;
   this.created_date  = created_date;
   this.UpdatedDate = UpdatedDate;
    
    
    
    }
    
    }
    
        
    public  List<Invlist> GetWaitlistfromWebService()
    {
    String myjson;
    String myUrl;
    List<WLMaster> WLMasterList= new List<WLMaster>() ;
    List<Invlist>  InvList1 = new List<Invlist>();
    List<WLJson> WLJsonlist = new List<WLJson>();
    
    integer i=0;   
    
 HttpRequest req = new HttpRequest();
   Http http = new Http();
   // set the method
   req.setMethod('GET');





  if (mMyPool == 'GetAllReservations')
  {
  //  myUrl = 'http://dev-es-i.api.move.com/reservations?format=json';

			Waitlist_Urls__c InventoryURL = Waitlist_Urls__c.getInstance('GetAllReservations');  
			
				System.debug('InventoryURL is ' + InventoryURL.url__c);
				if (InventoryURL.url__c != null) {	
					myUrl = InventoryURL.url__c; 	
				
				}	
    
    
    
    
  }else if(mMyPool == 'GetPendingAllocation')
  {
  //  myUrl = 'http://dev-es-i.api.move.com/pendingallocations?format=json';
    
      		Waitlist_Urls__c InventoryURL = Waitlist_Urls__c.getInstance('GetPendingAllocation');  
			
				System.debug('InventoryURL is ' + InventoryURL.url__c);
				if (InventoryURL.url__c != null) {	
					myUrl = InventoryURL.url__c; 	
				
				}	
    
      
      
      
  }else if(mMyPool == 'GetSalesEventPool')
  {
//   myUrl = 'http://dev-es-i.api.move.com/pendingallocations?format=json';
    
  			Waitlist_Urls__c InventoryURL = Waitlist_Urls__c.getInstance('GetSalesEventPool');  
			
				System.debug('InventoryURL is ' + InventoryURL.url__c);
				if (InventoryURL.url__c != null) {	
					myUrl = InventoryURL.url__c; 	
				
				}	
  
  }
  else
  {
 
    	Waitlist_Urls__c InventoryURL = Waitlist_Urls__c.getInstance('GetAllReservations');  
			
				System.debug('InventoryURL is ' + InventoryURL.url__c);
				if (InventoryURL.url__c != null) {	
					myUrl = InventoryURL.url__c; 	
				
				}	
    
    
  }


myUrl = myUrl +  mMyFilter ;



myUrl  = myUrl + '&' +  mMyLimit ;
myUrl  = myUrl + '&' +  mMyOrderBy ;
//myUrl = myUrl + '&' + mMyPageNo;

System.Debug('myUrl' + myUrl);

req.setEndpoint(myUrl); 
req.setHeader('Accept', 'application/json');


//HttpResponse res = http.send(req);
    
    try
    {
    //req.setTimeout(120000);
  //  req.setCompressed(true);
    HTTPResponse resp = http.send(req);
    
    
    
    myjson = resp.getBody();
    
    System.Debug('Arun myjson' +myjson);
    JSONParser parser =    JSON.createParser(myjson);
    System.Debug('Arun MYparser' +parser);
    
    while (parser.nextToken() != null) {
        System.debug('Current token: ' +
        parser.getCurrentToken() + parser.getCurrentName() + parser.getText());
        
        
            if(parser.getCurrentToken() == JSONToken.START_OBJECT && parser.getCurrentName()=='results')
            {
                
                System.debug('Arun : entered  Results Object');
                WLJson sto = (WLJson)parser.readValueAs(WLJson.class);
                System.debug('sto' +sto);
                WLJsonlist.add(sto);
                System.debug('*****Serialized WLJson: ' + WLJsonlist);
            } 
              else if(parser.getCurrentToken() == JSONToken.START_ARRAY )
              {
              
  System.debug('*****Entered START_ARRAY ');
              
                while (parser.nextToken() != null) {
                    // Check for JSON object starting
                    //  START_OBJECT This token is returned when  is encountered.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        
                                    System.debug('Arun : entered Parser results Object within Array');
                                    WLMaster sto = (WLMaster)parser.readValueAs(WLMaster.class);
                                    System.debug('sto' +sto);
                                    WLMasterList.add(sto);
                                    System.debug('*****Serialized WLMaster: ' +WLMasterList);
                                    
                                    
                                    
                             }// if start object
             
             
                                                      } // while loop
             
                } // else if end 
                
                
              
                
               }// parent while
      
        
        
        
        } // try catch block
    

    
    catch (Exception e)
   {
   
   System.Debug('Exception myjson' +myjson);
   //System.Debug('resp' +resp);
    System.Debug('e' + e);
   
   }

    
    try
    {
    

 System.Debug('Starting Deserialize');
 

    
    
    for (WLMaster obj1   :  WLMasterList )
    {

   Invlist WL = new Invlist();
  
 
  System.Debug('Create Inventory Object');
 
    try
    {
      
    for (WLJson obj2   :  obj1.reservation_line_items )
    {
   
    WL.reservation_id = obj1.reservation_id;
    WL.transaction_id = obj2.transaction_id;
    WL.party_id = obj2.party_id;
    
    
     System.Debug('Inside Object' + WL.party_id );
   
    
        
        WL.product_name = obj2.product_name;
    
        WL.product_type = obj2.product_type;
        
    WL.market_name = obj2.market_name;
    WL.line_item_id =obj2.line_item_id;
    WL.product_size =obj2.product_size;
    WL.inventory_pool = obj2.inventory_pool;
    WL.lead_type =      obj2.lead_type ;
    WL.market_state_id   =obj2.market_state_id   ;
    WL.reserved_quantity =obj2.reserved_quantity ;
    WL.market_id =  obj2.market_id ;
    WL.inventory_status = obj2.inventory_status;
   // WL.created_date  = created_date;
   // WL.UpdatedDate = UpdatedDate;
   WL.party_id = obj2.party_id; 
  
  try 
  {
     
       
    WL.lock_release_date = get_formatted_date(obj1.lock_release_date );
    WL.created_date = get_formatted_date(obj2.created_date ); 
    WL.UpdatedDate = get_formatted_date(obj2.UpdatedDate ); 
    System.debug('Date is ' + obj1.lock_release_date);
    
  //      String formattedDt = obj2.lock_release_date.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                        
    
    
   
  }catch(exception e)
  {
    System.debug('Error is ' + e.getMessage());
  
  }
   
        InvList1.add(WL) ; 
        
        
    } // end of inner for loop
    
    } // try block end 
    
    catch(exception e)
    {
    	// parsin issue , empty error go to next object
        
    }   
 
         
       
         i++;

    }
    

  System.debug('InvList1' + InvList1);


    }
    catch (Exception e)
    {
         System.debug('Excption Occured during DeSearialiation' + e.getMessage());
        
        
  return null ;
    
    
        
    }

    
     
    
    
    
    
    
    
    return InvList1;
    
    
    } // end of the class
    
    
    public class WLMaster
    {
   // string offset { get; set; }
   // string total { get; set; }
   public string  reservation_id  { get; set; }
   public string lock_release_date { get; set; }
     
   public List<WLJson> reservation_line_items{ get; set; }
   
        
        
        public  WLMaster(string reservation_id ,  List<WLJson> reservation_line_items , string lock_release_date)
    {
        
        System.debug('Arun : Entered Constructor WLMaster');
       // this.offset = offset;
       // this.total = total ;
        this.reservation_id = reservation_id;
        this.reservation_line_items = reservation_line_items;
        this.lock_release_date = lock_release_date;
        
    }
        
        
    }
    
    
 
    
    
    public class WLJson
    {
    
       public string party_id { get; set; }
       public string product_type { get; set; }
      
       public     string transaction_id { get; set; }
       public string line_item_id { get; set; }
    
    public string product_name { get; set; }
     public string product_size { get; set; }
     public string inventory_pool { get; set; }
     public string lead_type { get; set; }
     public string market_name { get; set; }
     public string market_state_id { get; set; }
     public string reserved_quantity { get; set; }
     public string lock_release_date { get; set; }
    
     
    public  string   market_id  { get; set; }
     public  string  inventory_status { get; set; }
      public  string  created_date  { get; set; }
       public  string   UpdatedDate { get; set; }
   
    
    
   
  /*
  "transaction_id":"106150","line_item_id":"1","product_name":"Connection for Co-Brokerage",
  "product_type":"City","product_size":"Half","inventory_pool":"available","lead_type":"Fast",
  "market_name":"Binder","market_state_id":"CA","reserved_quantity":1,"market_id":41501}],
  "party_id":"12345","lock_release_date":"2013-04-28T00:00:00.0000000+00:00"},*/
  
    
    public WLJson(
    
     string transaction_id ,
    string line_item_id ,
    string product_name ,
       string product_type ,
       string product_size ,
       string inventory_pool ,
    string lead_type ,
     string market_name ,
      string market_state_id ,
        string reserved_quantity ,
      string  market_id ,
      string party_id,
    string lock_release_date , 
     string  inventory_status ,
      string created_date  ,
      string UpdatedDate 
   
    
    )
    {
    	
    	try
    	{
        
    this.transaction_id= transaction_id ;
    this.party_id =party_id ;
    this.product_type =   product_type;
    this.market_name = market_name;
    this.line_item_id =line_item_id;
    this.product_name = product_name;
    
    this.product_size =product_size;
    this.inventory_pool = inventory_pool;
    this.lead_type =lead_type ;
    this.market_state_id   =market_state_id   ;
  
    this.reserved_quantity =reserved_quantity ;
    this.market_id =market_id ;
    
    
    this.lock_release_date =lock_release_date;
   System.debug('lock_release_date' + this.lock_release_date);
   this.inventory_status = inventory_status;
   this.created_date  = created_date;
   this.UpdatedDate = UpdatedDate;
    	}
    	catch (exception e)
    	{
    	
    		
    	}	
    		
    	} // end of function 
      
      
    } // end of class 
    
    
    
     String  get_formatted_date(string mydate )
    {
        String formattedDt;
        
        if (mydate != null)
        {
        	
   //     	DateTime scheduleTime = DateTime.valueofGmt( ‘Your Date Time to be Convert’);
        	
        	
                                try 
                          {
                             
                       					
                       
                           // string dttm = '2011-05-16T18:30:08.923-07:00';
                            string dttm = mydate ;
                            string dttm2 = dttm.replace('T',' ');
                            Integer indx = dttm2.indexOf('.');
                            string newstr = dttm2.substring(0,indx);
                            system.debug('===========Time=========  ' +newstr );
                            datetime objdt  = datetime.valueof(newstr );
                            system.debug('===========Final Time=========  ' +objdt  );
                           formattedDt = objdt.format('MM-dd-yyyy hh:mm:ss');
                 
                            
                          }catch(exception e)
                          {
                            System.debug('Error is ' + e.getMessage());
                          
                          }
        }                 
        
    return formattedDt;
        
        
    } // end of function get format date
    
public PageReference callHTTP()
{
    
    System.debug('Arun - Reached callHTTP');
    
    return CallReservationsUsingHTTP( mMymethod ,  mReservationID );
    
}

    
    public PageReference CallReservationsUsingHTTP(string mymethod , string ReservationID )
    {
         //   integer lock_party_id = MyPartyId;
       //string mydate = '2015-07-18T01:13:28.0000000+00:00';
       string mydate = MyLockReleaseDate;
       
        System.debug('Arun - CallReservationsUsingHTTP');

                System.debug('My LockRelease Date before format is ' + MyLockReleaseDate);

               
        
                System.debug('My LockRelease Date after format is ' + MyLockReleaseDate);
        
        
       String transaction_id = MyTransactionId;
      // String ReservationID = '160';
       string operation ;
       string message1 ;

  
       
  /*
   <transaction_id xmlns="">106165</transaction_id>
            <line_item_id xmlns="">1</line_item_id>
            <product_name xmlns="">Connection for Co-Brokerage</product_name>
            <product_type xmlns="">Postal Code</product_type>
            <product_size xmlns="">Full</product_size>
            <inventory_pool xmlns="">available</inventory_pool>
            <lead_type xmlns="">Flex</lead_type>
            <market_name xmlns="">00006</market_name>
            <market_state_id xmlns="">CA</market_state_id>
            <request_quantity xmlns="">1</request_quantity>
            <market_id xmlns="">6973</market_id>
  
  
  */
   system.debug('*****Lock Inventory status Before Reservation Item Init*****');
    
      
      system.debug('*****Lock Inventory status Init*****');
    
    
     string line_item = MyLineItemId;
        string market_id = MyMarketId;
        string market_name = MyMarketName;
        string product_name =MyProductName;
        string product_type =MyProductType;
        string product_size =MyProductSize;
        string lead_type = MyLeadType;
        string requested_quantity  =MyReservedQty;
        string market_state_id =MyMarketState;
        string inventory_pool =MyInventoryPool;
        
        try
        {
        
         HttpRequest req = new HttpRequest();
            Http http = new Http();
   // set the method
            
    string myUrl = 'http://dev-es-i.api.move.com/reservations/';
    
    Waitlist_Urls__c InventoryURL = Waitlist_Urls__c.getInstance('MakeReservations');  

	System.debug('InventoryURL is ' + InventoryURL.url__c);
	if (InventoryURL.url__c != null) {	
		myUrl = InventoryURL.url__c; 	
	
	}	
	
    
    
    
    
     myUrl = myUrl + ReservationId;

    req.setEndpoint(myUrl); 
    req.setHeader('Accept', 'application/json');
 //   req.setHeader('Accept-encoding', 'gzip,deflate');


       
       if (mymethod == 'Delete')
       {
        req.setMethod('DELETE');
       }
       else
       {
        req.setMethod('PUT');
        req.setHeader('content-type' , 'application/json');
        
        
        
        string body ;
body = '{';
body = body + '"reservation_line_items": [';
body = body + '{';
//body = body + '"line_item_id": "1",';
 
 body = body + '"line_item_id": "' + MyLineItemId + '",';
 

body = body + '"product_name": "' + MyProductName + '", ';
body = body + '"product_type": "' + MyProductType + '", ';
body = body + '"product_size": "' + MyProductSize + '", ' ;
body = body + '"inventory_pool": "'  + MyInventoryPool + '", ';
body = body + '"lead_type": "' +  MyLeadType + '", ';
body = body + '"market_name": "' +  MyMarketName + '", ';
body = body + '"market_state_id": "' + MyMarketState + '", ';
body = body + '"reserved_quantity": ' + MyReservedQty ;
body = body + '}';
body = body + '] ,';
body =body + '"party_id": "' + MyPartyId +'", ';
body = body + '"lock_release_date": "' + MyLockReleaseDate + '", ';
body = body + '"reservation_id": "' + ReservationID + '", ';
body = body + '"reserved_by": "' + MyReservedBy + '"';
body = body + '}';

///********************** working format ***********************/
/* body = '{"reservation_id": "31", "reservation_line_items": [ { "transaction_id": "17009", "line_item_id": "1",';
body = body + '"product_name": "Connection for Co-Brokerage","product_type": "Postal Code","product_size": "Full",';
 body = body + '"inventory_pool": "available","lead_type": "flex","market_name": "00009","market_state_id": "CA",';
 body = body + '"reserved_quantity": 1,"market_id": 22386}';                        
 body = body + '],"party_id": "12345","lock_release_date": "2016-01-01T00:00:00.0000000+00:00",';
 body = body + '"reserved_by": "arunsharma"}';
 
 */






 req.setBody(body); 

System.debug(req);        
System.debug(body);        
       }
            




//HttpResponse res = http.send(req);
    
    //req.setTimeout(120000);
    //req.setCompressed(true);
    
    
    HTTPResponse resp = http.send(req);
    
    
    
   string  myjson = resp.getBody();
        
    System.debug('HTTP Response is ' + myjson)  ;
        
        }
        catch (exception e)
        {
          System.debug('HTTP Response is ' + e.getMessage())    ;
            
            
        } 
        
    return null;    
        
    } // end of function call http
 
    
}