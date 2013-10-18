public abstract with sharing class EditableList 
{
  public final Integer ZERO {get; private set;}

  public sObject mysObject {get; protected set;}
  public List<sObject> childList {get; set;}
  
  // Used for removing elements from the list
  public String removeIndex {get; set;}
  @TestVisible protected List<sObject> removeChildList {get;set;} 

  public EditableList()
  {
    this.ZERO = 0;
    this.removeChildList = new List<sObject>();

    // Implementing class should can initialize this to retrieve existing
    // child records, OR this can be treated as a page where only new
    // items are added. If that is the case, then leave this as is.
    this.childList = new List<sObject>();
  }

  /*
   * Need to implement the following when implementing constructor:
   *
   *  - Query for child records, including all metadata to be shown on the page
   *    - Ensure query only returns the records associated with the parent
   *  - Set query results to childList List<sObject>
   */
	public EditableList(ApexPages.StandardController stdController) 
  {
    this();

    this.mysObject = (sObject)stdController.getRecord();
  }

  public virtual Boolean getHasChildren()
  {
    return !childList.isEmpty();
  }

  /* 
   * Need to implement the following pseudocode
   *
   *  - Initialize child record
   *  - Set any default values
   *  - Set relationship with parent
   */
  public virtual sObject initChildRecord()
  {
    // Cannot instantiate a generic sObject, must choose an actual object
    // Since this class needs to be overridden, this is a placeholder
    // implementation.
    return new Account();
  }

  public virtual void addToList()
  {
    childList.add(initChildRecord());
  }

  public virtual void removeFromList()
  {
    try
    {
      // removeIndex is one based
      Integer rowIndex = Integer.valueOf(removeIndex) - 1;
      
      if (childList.size() > rowIndex && rowIndex >= 0)
      {
        sObject sobj = childList.remove(rowIndex);
        
        // Need to delete it if it existed in the database
        if (sobj.Id != null)
        {       
          removeChildList.add(sobj);
        }
      }
    }
    catch (Exception e)
    {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    }
  }

  public virtual PageReference save()
  {
    Savepoint sp = Database.setSavepoint();
            
    try
    {
      upsert castList(childList);
      delete castList(removeChildList);
      
      String retURL = ApexPages.currentPage().getParameters().get('retURL');
      // If retURL doesn't exist, simply return to parent record
      if (String.isBlank(retURL))
      {
        retURL = '/' + mysObject.Id;
      }
      
      PageReference pr = new PageReference(retURL);
      pr.setRedirect(true);
      return pr;
    }
    catch(Exception e)
    {
      Database.rollback(sp);
                
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
      return null;
    } 
  } 

  /*
   * This is a hook that allows you to cast your List<sObject> to another
   * object type. Override it in the implementation class.
   */
  public virtual List<sObject> castList(List<sObject> myList)
  {
    return myList;
  }
}