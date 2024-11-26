# Extract-parts

The tool extracts one or more parts from a musical score such as _clarinet I. + basson II_., etc.. 

## Usage

For testing purposes, you can first try the data in `./tests/data/*`. 

For example, let's extract a first clarinet from the Symphonie by W. A. Mozart, K. 550 (`./tests/data/550-001.mei`):

<img width="700" alt="K. 550-001" src="https://github.com/user-attachments/assets/bd269f87-4cc1-4b5f-bd8b-8cbfce093827">

Select the `3.1` option in `./config/config.xml` (third `<staff>`, second `<layer>`).

<img width="700" alt="config.xml" src="https://github.com/user-attachments/assets/8a661ab1-62ec-4c84-90f2-3ce8e04d9df8">

Apply the transformation scenario `extract-parts` on the file `550-001.mei`:

<img width="700" alt="Configure transformation scenario." src="https://github.com/user-attachments/assets/d3a35d50-4aa5-477b-865d-6bcff4a864ac">

The output will be a file `550-001_3.1.mei` in the same repository:

<img width="700" alt="Clarinetto I" src="https://github.com/user-attachments/assets/53a693f3-2c9c-43ee-a1a3-03a304f895c6">




## Parameters:

- `P_GLOBAL_CONTEXT_ITEM and P_XSPEC_TEST`
  Both parameters are used in the context of XSpec unit testing only.

- `P_LANGUAGE`  
  Language for displaying instrument names. Possible values: 'IT' (default), 'EN', 'DE'.


- `P_MOVI` 
  The parameter should be set to `true()` if the stylesheet is called from MoVi or any other web application.

- `P_OUTPUT_PATH`

- `P_REQUESTED_PARTS`  
  The parameter can be passed either via CLI or by utilizing the GUI implemented in oXygen XML Editor. To access the GUI, open the file `/config/config.xml` in Author mode. The syntax of the parameter is as follows: *|&lt;staffNumber>[.&lt;layerNumber>]?|*. For instance, *|2.2|* refers to the second staff, second layer. Note that the layer-part is optional. If you want to extract the second staff completely, you have to pass *|2|*. Multiple combinations are possible, e.g. *|2.2.|4.1|5|*. If all parts contained in the score are requested, e.g. *|1|2|3|4|* for a string quartet, the file will be simply copied.

- `P_SHRINK_MEASURES`  
  Enables the feature of creating `<multiRest>`s. Default is `true()`.

<hr>

**Notes:**

- If the MEI file contains multiple `<scoreDef>`s with a different number of staves, the tool might not work properly. The workaround is to temporarily comment out the score portions.

**Current version**: _3.1.0_. For details see the CHANGELOG.

**Author**: oleksii.sapov-erlinger@mozarteum.at
