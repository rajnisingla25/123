@isTest
private class AssetStructure_test{
    static testMethod void method1(){
        AssetStructure assStr = new AssetStructure();
            assStr.type = 'test';
            assStr.SoldToaccountId = 'test';
            assStr.assetId = 'test';
            assStr.parentlevel = 100;
            assStr.HLC = 10.256;
            assStr.HLCOverride = 12.56;
        List<AssetStructure.fulfillTo> asstLst = new List<AssetStructure.fulfillTo>();    
        AssetStructure.fulfillTo ff = new AssetStructure.fulfillTo();
           ff.Type = 'test';
           ff.FulfillToaccountId = 'test';
           ff.assetId = 'test';
           ff.fulfilltolevel = 10 ;
           ff.HLC = 100.03;
           ff.HLCOverride = 100.03 ;
        asstLst.add(ff);
           //.participant = asstLst; 
        List<AssetStructure.participant> parLst = new List<AssetStructure.participant>();       
        AssetStructure.participant par = new AssetStructure.participant();
           par.Type = 'test';
           par.participantaccountId = 'test';
           par.assetId = 'test';
           par.MLSSETID = 'test' ;
           par.participantlevel = 10;
           par.HLC = 100.03;
           par.HLCOverride = 100.03 ;
         parLst.add(par); 
        
    }
}