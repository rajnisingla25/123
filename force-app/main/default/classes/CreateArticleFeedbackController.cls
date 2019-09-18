//
// (c) 2015 Appirio, Inc.
//
// Apex Class Name: CreateArticleFeedbackController
// Description: This Class is Used to create an Article Feedback for An Article Object
//
// 25th March 2015    Ravindra Shekhawat    Original (Task # T-373305 )
//
public without sharing class CreateArticleFeedbackController { 
    public Article_Feedback__c articleFeedback {get; set;}
    public KnowledgeArticleVersion knowledgeArticle {get; set;}
    private String articleId;
    private String articleQuery = 'SELECT Id, ArticleNumber, ArticleType, Title FROM KnowledgeArticleVersion'+
                                     ' WHERE  PublishStatus=\'Online\' AND IsLatestVersion=true AND KnowledgeArticleId=';
    public Map<String,String> describeMap = new Map<String,String>();
    
    public CreateArticleFeedbackController () {
        articleFeedback = new Article_Feedback__c ();
        createDescribeMap();
    }
     
    // This Method Creates an Creates an Article Feedback on An Article
    //  @param
    //  @return a PageReference
    public PageReference createArticleFeedback() {
        // Check for Article if The current SObject is of Article Type
        if(articleFeedback.Comments__c == null || articleFeedback.Comments__c == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Provide Feedback For Article'));
            return null;
        }
        String articleName = checkForArticle();
        if(checkForArticle()!=null){
             getArticle(articleName);
             if(knowledgeArticle!=null){
                 createNewArticleFeedback();
                 articleFeedback = new Article_Feedback__c ();
             }else{
                 articleFeedback = new Article_Feedback__c ();
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot create Article Feedback on Unpublished Articles'));
            }
        }else{
            // Send Error Message For Non Article Type SObjects
            articleFeedback = new Article_Feedback__c ();
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'You Cannot Create Article Feedback For Non-Article Type Objects');
            ApexPages.addMessage(msg);
        }
        return null;
    }
      
     // This method creates a new Article Feedback object and posts a Feed on that Article
     //  @param 
     //  @return 
     private void createNewArticleFeedback() {      
        try {
            articleFeedback.Article_Number__c = knowledgeArticle.ArticleNumber;
            articleFeedback.Article_Title__c = knowledgeArticle.Title;
            articleFeedback.Article_Id__c = articleId;
            articleFeedback.Status__c = 'New';
            
            insert articleFeedback ;
            
            //Insert FeedPost on Article
            FeedItem post = new FeedItem();
            post.ParentId = ApexPages.currentPage().getParameters().get('id');
            //post.Body = 'Feedback : '+articleFeedback.Comments__c +'\n Is Helpful : '+(articleFeedback.Is_Helpful__c == true ? 'Yes ' : 'No');
            post.Body = 'Feedback : '+articleFeedback.Comments__c +'\n Is Helpful : '+(articleFeedback.Was_this_Article_Helpful__c);
            post.type = Constants.LINKPOST_ARTICLE; 
            post.LinkUrl = '/' + articleFeedback.id;
            post.Title = Constants.ARTICLE_FEEDBACK;
            insert post;
        } catch(System.Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    } 
    
    // Create DescribeMap for Article Types
    //  @param
    //  @return
    private void createDescribeMap() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Set<String> keySet = gd.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = gd.get(key);
            // Put all The Article Types in The Map
            if (key.startsWith('ka') || key.endsWith('_kav')) {
                this.describeMap.put(objectType.getDescribe().getKeyPrefix(), objectType.getDescribe().getName());
            }
        }
    }

    
    // Check if the Current SObject is of Article Type
    //  @param
    //  @return
    private String checkForArticle(){
        articleId = ApexPages.currentPage().getParameters().get('id');
       
        String articlePrefix = articleId.substring(0,3);
        Set<String> keySet = describeMap.keySet();
        String objectName = null;
        for(String key: keySet) {
            if(articlePrefix.equalsIgnoreCase(key)) {
                objectName = describeMap.get(key);
                return objectName;
            }
        }
        return objectName;
    }
      
     // Get the Article from Article ID
     //  @param objectName a String
     //  @return
     private void getArticle(String objectName){
        System.debug('Final Query is :'+articleQuery+'\''+articleId+'\'');
        List<KnowledgeArticleVersion> knowledgeArticles = new List<KnowledgeArticleVersion>();
         try{
             knowledgeArticles = Database.query(articleQuery+'\''+articleId+'\'');
             if(knowledgeArticles.size()!=0){
                 knowledgeArticle = knowledgeArticles.get(0);
                 System.debug('knowledgeArticle :'+knowledgeArticle);
             }
         }catch(QueryException qe){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Constants.GENERIC_ERROR_MSG));
         }
         
     }  
    }