//****************************************************************************************
//Name          : CustomPaginator 
//Date          : 05-JAN-2016
//Created by    : NTT Data
//Author        : Stanley Sequeira
//Description   : This Class is meant for pagination for CBC Performance Report
//               
// *****************************************************************************************

public without sharing class CustomPaginator { 


  public class Paginator {
    CustomPaginator dummayInstance = new CustomPaginator();
    private final Integer RESULTS_PER_PAGE;
    private boolean isOkey;
    public boolean isOkey(){ return isOkey;}
    public integer totalResults {set; get;}
    public Integer currentPage {set; get;}
    public Integer totalPage {set; get;}
    private Integer showingFrom;
    private Integer showingTo;
    private List<List<AccountAssetInvWrapper>> allResults = new List<List<AccountAssetInvWrapper>>();
    public boolean isNextPageAvailable {set; get;}
    public boolean isPreviousPageAvailable {set; get;}
      
    public Paginator(Integer ppResults, List<AccountAssetInvWrapper> wrapperResultLst){
      
      isOkey = false;
      RESULTS_PER_PAGE = ppResults;
      totalResults = 0;
      
      try{
        allResults.add(wrapperResultLst);
        totalResults = totalResults + wrapperResultLst.size();
        init();
        isOkey = true;
        
      }catch(exception e){
        isOkey = false;
      }
    }
    
    public Integer getShowingFrom(){
      
      showingFrom = (currentPage * RESULTS_PER_PAGE ) - RESULTS_PER_PAGE + 1;
      return showingFrom;
    }
    
    public Integer getShowingTo(){
      
      showingTo = currentPage * RESULTS_PER_PAGE ;
      if (totalResults < showingTo){
        showingTo = totalResults;
      }
      return showingTo;
    }
            
    public List<AccountAssetInvWrapper> getPage(Integer pageNo){
      
      AccountAssetInvWrapper[] selectedResult =  new AccountAssetInvWrapper[RESULTS_PER_PAGE];
      Integer endTo = RESULTS_PER_PAGE * pageNo;
      Integer startFrom = endTo - RESULTS_PER_PAGE;
      Integer currentRecordNo = 0;
      Integer resultIndex = 0;
      Integer recordIndex = -1;
      
      for (AccountAssetInvWrapper[] recordBatch:allResults){
        
        currentRecordNo = currentRecordNo + recordBatch.size();
        
        if (currentRecordNo >= startFrom ){
          
          for (AccountAssetInvWrapper record:recordBatch){
            recordIndex++;
            
            if (recordIndex >= startFrom && recordIndex <= endTo && resultIndex<RESULTS_PER_PAGE){
              selectedResult[resultIndex] = record ;
              resultIndex++ ;
            }else if (resultIndex == RESULTS_PER_PAGE){
              break;
            }
            
          }
        }else{
          recordIndex += recordBatch.size(); 
          if (resultIndex == RESULTS_PER_PAGE){
            break;
          }
        }
      }
      return selectedResult;
    } 
        
    public List<AccountAssetInvWrapper> getFirstPage(){
      
      currentPage = 1;
      updateNavigationStatus();
      return getPage(1);
    }
    
    public List<AccountAssetInvWrapper> getLastPage(){
      
      currentPage = totalPage;
      updateNavigationStatus();
      return getPage(totalPage);
    }
        
    public void updateNavigationStatus(){
      
      if (totalPage >1){
        isNextPageAvailable = currentPage < totalPage ? true : false;
        isPreviousPageAvailable = currentPage > 1 ? true : false;
        
      } else {
        isNextPageAvailable = false;
        isPreviousPageAvailable = false;
      }
    }  
  
    public List<AccountAssetInvWrapper> getNextPage(){
      
      updateNavigationStatus();
      
      if (isNextPageAvailable){
        currentPage ++;
      }
      updateNavigationStatus();
      return getPage(currentPage);
    }
    
    public List<AccountAssetInvWrapper> getPreviousPage(){
      
      updateNavigationStatus();
      
      if (isPreviousPageAvailable){
        currentPage --;
      }
      updateNavigationStatus();
      return getPage(currentPage);
    }
    
    private void init(){
      
      currentPage = 1;
      totalPage = totalResults / RESULTS_PER_PAGE ;
      
      if (totalPage * RESULTS_PER_PAGE < totalResults){
        totalPage++;
      }
      
      isNextPageAvailable = currentPage < totalPage ?  true : false;
      isPreviousPageAvailable = false;
    }
  }
}