Visualforce Edit Multiple Records
=================================

This project contains a Visualforce template and example on how to create a an editable table of records, including adding and deleting. More specifically, the example involved is creating an editable screen to allow managing of Contact records against an Account.

![](http://mwelburn.github.com/Visualforce-Edit-Multiple-Records/images/View - Editing Records.png)

The package does not include a default Account layout that is already customized in an attempt to not override any existing Page Layout. The custom buttons need to be manually added to the Page Layout.

For more information on setup, please click [here](http://mwelburn.github.io/Visualforce-Edit-Multiple-Records/)

Implementation Notes
----

This code was implemented using by creating a base class with as many generic implementations of logic as possible. This was done by making all references to objects as [sObject](http://www.salesforce.com/us/developer/docs/apexcode/Content/langCon_apex_SObjects.htm), the base object type for all Salesforce objects. Each subsequent implementation of the child related list will require an implementation class tailored to the object type that is to be manipulated, as well as making customizations to the Visualforce page due to different fields being displayed.

The code involved breaks down into three main files:

* EditableList.cls

  This is an abstract class that controller extensions can implement that defines generic implementation methods for manipulating the table, as well as persisting and deleting records.
  

* EditableContactListExtension.cls

  This is a sample implementation class for an Account controller extension. Only the required method overrides are implemented.
  

* EditableContactList.page

  Sample Visualforce implementation for managing Contact records against an Account. Allows adding, editing, and removing child records. This file will require modifications to add or remove different fields from the table.


Installation Link
----
  
* [https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti00000003vvQ](https://login.salesforce.com/packaging/installPackage.apexp?p0=04ti00000003vvQ)
* **Note**: not guaranteed to be current
* To install to a sandbox environment, change the subdomain from login to test