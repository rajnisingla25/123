@isTest
public class CustomPaginator_Test{
    Static testMethod void CustomPaginatorTesting(){
        
        
          MoveTestDataUtilClass mtduc = new MoveTestDataUtilClass();
          AccountAssetInvWrapper aaIw = new AccountAssetInvWrapper();
          InventoryInformation ii = new InventoryInformation();
          InventoryInformation.AssetLeadDetails inald = new InventoryInformation.AssetLeadDetails();
          AccountAssetInvWrapper.AssetLeadDetails aaiald = new AccountAssetInvWrapper.AssetLeadDetails(inald);
          Asset asst = new Asset();
          AccountAssetInvWrapper.AssetDetails aaiad = new AccountAssetInvWrapper.AssetDetails(asst,ii);
          //aaiald.
          Account Acc = new Account();
          List<Asset> ppassdetails = new List<Asset>();
          List<InventoryInformation> assinv = new List<InventoryInformation>();
          AccountAssetInvWrapper aaIw1 = new AccountAssetInvWrapper(Acc,ppassdetails,assinv);
          
          List<AccountAssetInvWrapper> wrapperResultLst = New List<AccountAssetInvWrapper>();
          wrapperResultLst.add(aaIw1);
          Integer ppResults = 5;
          Integer pageNo =1;
          CustomPaginator cp = New CustomPaginator();
          CustomPaginator.Paginator pg= New CustomPaginator.Paginator(ppResults , wrapperResultLst);
              pg.isOkey(); 
              pg.getShowingFrom();
              pg.getShowingTo();
              pg.getPage(pageNo);
              pg.getFirstPage();
              pg.getLastPage();
              pg.updateNavigationStatus();
              pg.getNextPage();
              pg.getPreviousPage();
    }
}