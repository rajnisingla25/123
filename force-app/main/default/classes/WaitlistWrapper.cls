public with sharing class WaitlistWrapper implements Comparable {

public DataController.Waitlist WL;
public static string sortdirection ;
public static string sortbycolumn;
public static string sortby ='status desc token asc';


 // Constructor
    public WaitlistWrapper(DataController.Waitlist wl , string ssortdirection ,
    string ssortbycolumn , string ssortby)
   {
      
        WL = wl;
        sortdirection =ssortdirection ;
        sortbycolumn = ssortbycolumn;
        sortby = ssortby;
        System.debug('Arun 1 WLWrapper ' +WL + 'wl' + wl);
    }

public Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        WaitlistWrapper compareToWL = (WaitlistWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        
        if (sortby !=null)
        {
          ////
           System.debug('Sort by ' + sortby);
           String[] result = sortby.split(' \\s*');
           sortbycolumn = result[0];
           sortdirection = result[1];
            System.debug('result[0] ' + result[0]);
            System.debug('result[1] ' + result[1]);
           
        } 
        
        
     if    (sortbycolumn == 'token')
      
     {   
         if (compareToWL.WL.token != null) {
            
                   if (sortdirection =='asc')
                   {
            
                  if (WL.token > compareToWL.WL.token) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  } else if (WL.token < compareToWL.WL.token) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  }
                   }
                   
                   else // desc search
                   {
                     
                      if (WL.token > compareToWL.WL.token) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  } else if (WL.token < compareToWL.WL.token) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  }
                     
                     
                     
                   }
                   
                   
                   
                   
                   
                       
           
        }

   
     }// end of token If
     
     
          if    (sortbycolumn == 'status')
      
     {   
         if (compareToWL.WL.token != null) {
            
                   if (sortdirection =='asc')
                   {
            
                  if (WL.status > compareToWL.WL.status) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  } else if (WL.status < compareToWL.WL.status) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  }
                   }
                   
                   else // desc search
                   {
                     
                      if (WL.status > compareToWL.WL.status) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  } else if (WL.status < compareToWL.WL.status) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  }
                     
                     
                     
                   }
                   
                   
                   
                   
                   
         }               
           
        }//end of status If 
        
        
          if    (sortbycolumn == 'geo')
      
     {   
       
       System.debug('sortbycolumnArun' + sortbycolumn +',' + sortdirection );
       
         if (compareToWL.WL.geo != null) {
            
                   if (sortdirection =='asc')
                   {
            
                  if (WL.geo > compareToWL.WL.geo) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  } else if (WL.geo < compareToWL.WL.geo) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  }
                   }
                   
                   else // desc search
                   {
                     
                      if (WL.geo > compareToWL.WL.geo) {
                      // Set return value to a negative value.
                      returnValue = -1;
                  } else if (WL.geo < compareToWL.WL.geo) {
                      // Set return value to a positive value.
                      returnValue = 1;
                  }
                     
                     
                     
                   } // else desc search end
                   
                   
                   
                   
                   
                       
           
        }

   
     } // end of market GEO if
     
   
 return returnValue;  

} // end of procedure compareto

} // end of class