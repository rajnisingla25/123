// (c) 2015 Appirio, Inc.
//
// Class Name: CaseCommentsComponentController
// Description: Contoller Class for CaseComment Related List
//
// 27th March 2015    Ravindra Shekhawat   Original (Task # T-T-373931)
//21 April 2016 Krishna Bodala NewReq( LEAP-8453) to show up Child case comments Related List
public without sharing class CaseCommentsComponentController { 
    public Id parentCaseId {get; set;}
    public Id currentCaseId {get; set;}
    public list<Id> childCases{get;set;}
    //  set controller
 
    public cComments[] comments{
    get{
        List<cComments> comments = new List<cComments>();
        set<Id> caseCommentIdSet = new set<Id>();
        if(parentCaseId != null){
            caseCommentIdSet.add(parentCaseId);
        }
        else if(childCases != null && childCases.size() > 0){
            caseCommentIdSet.addAll(childCases);
        }
        for(CaseComment comment : [Select LastModifiedDate, ParentId, LastModifiedBy.Id, LastModifiedBy.Name, IsPublished, 
                    CreatedDate, Parent.CaseNumber, CreatedBy.Id, CreatedBy.Name, CommentBody
                    From CaseComment c where ParentId = :caseCommentIdSet order by c.LastModifiedDate desc])            
        {
            cComments tempcComment = new cComments();
            tempcComment.cComment = comment;

            // Build String to display.
            tempcComment.commentText = (childCases != null && childCases.size() > 0) ? 
                                    '<b>Case Number : <a href=\'/' + comment.ParentId + '\' target="_blank">' + comment.Parent.CaseNumber + '</a>  ' : tempcComment.commentText;
            tempcComment.commentText = (tempcComment.commentText == null) ?
            '<b>Created By: <a href=\'/' + comment.CreatedBy.Id + '\'>' + comment.CreatedBy.Name + '</a> (' + comment.CreatedDate.format() + ') | ' : tempcComment.commentText;
            tempcComment.commentText += 'Last Modified By: <a href=\'/' + comment.LastModifiedBy.Id + '\'>' + comment.LastModifiedBy.Name + '</a> (' + comment.LastModifiedDate.format() + ')</b> ';
            tempcComment.commentText += comment.CommentBody;

            if(comment.IsPublished) 
                tempcComment.PublicPrivateAction = 'Make Private';
            else
                tempcComment.PublicPrivateAction = 'Make Public';
            //Add to list
            comments.add(tempcComment); 
        }
    return comments;
    }
    set;
  }


// This Method is Used to Delete A Comment
public PageReference deleteComment(){
    Id commentId = ApexPages.currentPage().getParameters().get('CommentId_d');

    for(cComments Comment : comments){
        if(Comment.cComment.Id == commentId){   
            delete Comment.cComment;    
            break;
        }
    }

    return null;
}   

  // Wrapper Class For Case Comments
  public class cComments {

    public CaseComment cComment {get; set;}
    public String commentText {get; set;}
    public String PublicPrivateAction {get; set;}
  }
  
}