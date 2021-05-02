
I used Core Data to store the products items and Category enum to store the product types.

I created 'ProductModel' Class to store the items(that will be shown in the table) & all the methods that connect to the DB(Insert,delete,update).

The 'ProductListVC' Class is a UITableView of the items - The Table is divided by the categories of the products.
The 'NewProductVC' Class is for adding new products and contains:
1) Text Field for product name
2) Button for selecting product category
3) Button to take product image - I used 'UIImagePickerController' for taking the photo.
4) Button to scan product barcode  - (BarCodeScannerVC) I used 'AVCaptureSession' to show camera and scan barcode of the product.


Before each use of the camera I checked for camera permission:
1) authorized - Start camera
2) notDetermined - Request permission
3) denied & restricted - Display a popup to the user and asking to give access in the app settings.

I used also some extensions to set the UI with constraints.
