/*
 * EditableList.cls
 *
 * Copyright (c)2013, Michael Welburn.
 * License: MIT
 *
 * Usage:
 *   This is the definition class where generic implementations of
 *   the table generating and modifications are implemented. This class
 *   should not be modified in order to implement the Visualforce table,
 *   all modifications should go in a controller extension that extends
 *   this class.
 *
 */
public abstract with sharing class EditableList 
{
  // Used to help instantiate a counter for the Visualforce table rows
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

    // Implementing class can initialize this to retrieve existing
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

  /*
   * Used to determine whether to display a message or the table
   */
  public Boolean getHasChildren()
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
    return new Contact();
  }

  /*
   * Used to add a new row to the table
   */
  public void addToList()
  {
    childList.add(initChildRecord());
  }

  /*
   * Used to remove a particular row from the table, referencing the
   * removeIndex that is set on the Visualforce page
   */
  public void removeFromList()
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

  /*
   * Defines the Page that is returned upon a successful save
   */
  public virtual PageReference getSuccessURL()
  {
    PageReference pr;

    String retURL = ApexPages.currentPage().getParameters().get('retURL');
    // If retURL doesn't exist, simply return to parent record
    if (String.isBlank(retURL))
    {
      pr = new ApexPages.StandardController(mysObject).view();
    }
    else
    {
      pr = new PageReference(retURL);
    }
    
    pr.setRedirect(true);
    return pr;
  }

  /*
   * Persists the records saved in the table, or deletes existing records
   * that the user deleted in the table.
   */
  public PageReference save()
  {
    Savepoint sp = Database.setSavepoint();
            
    try
    {
      // DML Upsert isn't supported for List<sObject>, so we need to do
      // explicit separate insert and update
      List<sObject> insertChildList = new List<sObject>();
      List<sObject> updateChildList = new List<sObject>();
      for (sObject sobj : childList)
      {
        if (sobj.Id == null)
        {
          insertChildList.add(sobj);
        }
        else
        {
          updateChildList.add(sobj);
        }
      }

      insert insertChildList;
      update updateChildList;
      delete removeChildList;
      
      return getSuccessURL();
    }
    catch(Exception e)
    {
      Database.rollback(sp);
                
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            
      return null;
    } 
  } 
}