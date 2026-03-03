/*
    Library: AlQalam (The Pen)
    Wrapper for C++ Extension
*/

if iswindows()
    loadlib("alqalam.dll")
else
    loadlib("libalqalam.so")
ok




/*
    Function: formatNanoTime
    Description: Formats a time duration in nanoseconds into a human-readable string.
    Parameters: nNs (Number) - Time duration in nanoseconds
    Returns: String
*/
func formatNanoTime nNs
    
    # 1. Nanoseconds 
    if nNs < 1000 return "" + floor(nNs) + " ns" ok
    
    # 2. Microseconds 
    if nNs < 1000000 val = nNs / 1000.0 return "" + formatDecimal(val) + " us" ok
    
    # 3. Milliseconds 
    if nNs < 1000000000 val = nNs / 1000000.0 return "" + formatDecimal(val) + " ms"ok
    
    # 4. Seconds & Hours 
    # Convert nanoseconds to seconds
    nSec = floor(nNs / 1000000000)
    
    nH = floor(nSec / 3600)
    nM = floor((nSec % 3600) / 60)
    nS = nSec % 60
    
    cStr = ""
    if nH > 0 cStr += "" + nH + "h " ok
    if nM > 0 cStr += "" + nM + "m " ok
    
    # Add seconds
    cStr += "" + nS + "s"
    
    return cStr

/*
    Function: formatDecimal
    Description: Formats a decimal number to a string with two decimal places.
    Parameters: nNum (Number) - The number to format
    Returns: String
*/
func formatDecimal nNum
    return floor(nNum * 100) / 100.0



/*
    Class: QalamChronos
    Description: High-Precision Timekeeper (Nanosecond Accuracy).
*/
class QalamChronos

    pPtr = NULL

    # --- Constructor ---
    func init() {
        pPtr = qalam_timer_init()
        return self
    }

    # reset chronos
    func reset() {
        qalam_timer_reset(pPtr)
    }

    # elapsed time in human-readable format
    func elapsed() {
        return formatNanoTime(qalam_timer_elapsed_ns(pPtr))
    }

    # elapsed time in nanoseconds
    func elapsed_ns() {
        
        return qalam_timer_elapsed_ns(pPtr)
    }

/*
    Class: QalamVector
    Description: A high-performance numeric array (The Inkwell of Numbers).
*/
class QalamVector

    # --- Properties ---
    pPtr = NULL
    
    # Constants for Fast Loop Operations (C++ OpCodes)
    OP_SET = 1
    OP_ADD = 2
    OP_MUL = 3

    # --- Constants for Process Modes ---
    MODE_CLIP       = 10
    MODE_THRESHOLD  = 11
    MODE_SCALE_ADD  = 12
    MODE_SUM_RANGE  = 20
    MODE_FIND_GT    = 30

    /*
        Function: init
        Description: Initializes the vector with [0] capacity.
        Parameters: nCapacity (Number)
    */
    func init(nCapacity) {
        pPtr = qalam_vector_init(nCapacity)
        return self
    }

    # ---------------------------------------------------------
    # 1. Flow & Access (Basic I/O)
    # ---------------------------------------------------------

    /*
        Function: flow
        Description: Pushes a new value to the end of the stream.
        Parameters: nValue (Number)
    */
    func flow(nValue) {
        qalam_vector_add(pPtr, nValue)
    }

    /*
        Function: read
        Description: Reads a value from a specific position.
        Parameters: nIndex (Number) - 1-based index
        Returns: Number
    */
    func read(nIndex) {
        return qalam_vector_get(pPtr, nIndex)
    }

    /*
        Function: write
        Description: Writes a value to a specific position.
                     Note: Requires 'qalam_vector_set' in C++ (if implemented).
                     Currently maps to internal logic or future expansion.
        Parameters: nIndex (Number), nValue (Number)
    */
    func write(nIndex, nValue) {
        # Assuming qalam_vector_set exists in C extension, 
        # otherwise this acts as a placeholder for architectural consistency.
        qalam_vector_set(pPtr, nIndex, nValue) 
    }

    /*
        Function: size
        Description: Returns current number of elements.
    */
    func size() {
        return qalam_vector_size(pPtr)
    }

    # ---------------------------------------------------------
    # 2. Alchemy (Batch Operations)
    # ---------------------------------------------------------

    /*
        Function: flood
        Description: Fills the entire vector with one value instantly.
        Parameters: nValue (Number)
    */
    func flood(nValue) {
        qalam_vector_run_loop(pPtr, OP_SET, nValue)
    }

    /*
        Function: elevate
        Description: Adds a scalar value to every element.
        Parameters: nBias (Number)
    */
    func elevate(nBias) {
        qalam_vector_run_loop(pPtr, OP_ADD, nBias)
    }

    /*
        Function: amplify
        Description: Multiplies every element by a factor.
        Parameters: nFactor (Number)
    */
    func amplify(nFactor) {
        qalam_vector_run_loop(pPtr, OP_MUL, nFactor)
    }

    func getRawPointer() {
        return qalam_vector_get_ptr(pPtr)
    }

    # ---------------------------------------------------------
    # 3. Transmutation (Bridge to Tensor)
    # ---------------------------------------------------------

    /*
        Function: toTensor
        Description: Converts the vector into a RingTensor View (Zero-Copy).
        Parameters: nRows (Number), nCols (Number)
        Returns: Tensor Object
    */
    func toTensor(nRows, nCols) {
        # 1. Get raw C++ memory address
        nAddr = qalam_vector_get_ptr(pPtr)
        
        # 2. Bridge to RingTensor using the helper we added
        # (Assuming 'tensor_from_memory' is registered in RingTensor C-Ext)
        pTensorStruct = tensor_from_memory(nAddr, nRows, nCols)
        
        # 3. Wrap in Ring Object
        oT = new Tensor(1, 1) # Dummy Init
        oT.pData = pTensorStruct
        oT.nRows = nRows
        oT.nCols = nCols
        
        return oT
    }

    /*
        Func: correct
        Desc: Modifies a value at a specific index.
              Replaces 'set'.
    */
    func correct(nIndex, nValue) {
        qalam_vector_set(pPtr, nIndex, nValue)
    }

    /*
        Func: wipe
        Desc: Removes all data, resetting size to 0.
    */
    func wipe() {
        qalam_vector_clear(pPtr)
    }

    /*
        Func: expand
        Desc: Forces the vector to a specific size.
    */
    func expand(nNewSize) {
        qalam_vector_resize(pPtr, nNewSize)
    }

    /*
        Func: prepare
        Desc: Reserves memory capacity without changing size (Performance).
    */
    func prepare(nCapacity) {
        qalam_vector_reserve(pPtr, nCapacity)
    }

    /*
        Func: loadFromPtr
        Desc: Loads data directly from memory address (Pointer).
    */
    func loadFromPtr(nAddr, nCount) {
        qalam_vector_load_from_ptr(pPtr, nAddr, nCount)
    }

    /*
        Func: flowFromPtr
        Desc: Appends data directly from memory address (Pointer).
    */
    func flowFromPtr(nAddr, nCount) {
        qalam_vector_append_from_ptr(pPtr, nAddr, nCount)
    }

    /*
        Func: process
        Desc: The Super Loop. Executes C++ logic on the vector.
    */
    func process nMode, p1, p2, p3
        # Flexible call allowing optional args (default 0)
        return qalam_vector_process(pPtr, nMode, p1, p2, p3)

    # --- High-Level Eloquent Wrappers ---

    func clip nMin, nMax
        process(MODE_CLIP, nMin, nMax, 0)
    
    func threshold nLimit, nReplacement
        process(MODE_THRESHOLD, nLimit, nReplacement, 0)

    func findFirstGreater nVal
        return process(MODE_FIND_GT, nVal, 0, 0)

    # --- Disk I/O ---

    func saveBinary cPath
        qalam_vector_save_binary(pPtr, cPath)

    func loadBinary cPath
        qalam_vector_load_binary(pPtr, cPath)

     /*
        Func: transform
        Desc: Applies a formula string directly.
    */
    func transform cExpr
        oF = new QalamFormula(cExpr)
        oF.applyTo(self)

    /*
        Func: stream
        Desc: Reads a block of data directly from a binary file into vector memory.
        Params: 1. File Path, 2. Start Offset, 3. Elements Count, 4. Mode ("load" or "upload")
    */
    func stream(cPath, nOffset, nCount, cMode) {
        return qalam_vector_stream(pPtr, cPath, nOffset, nCount, cMode)
    }

/*
    Class: QalamInk
    Description: A high-performance String Builder (The Inkwell of Text).
*/
class QalamInk

    pPtr = NULL

    func init {
        pPtr = qalam_ink_init()
        return self
    }

    /*
        Function: inscribe
        Description: Appends text to the buffer.
        Parameters: cText (String)
    */
    func inscribe(cText) {
        qalam_ink_append(pPtr, cText)
    }

    /*
        Function: inscribeBatch
        Description: Appends a list of strings efficiently (The Batch Processor).
        Parameters: aList (List of Strings)
    */
    func inscribeBatch(aList) {
        qalam_ink_append_batch(pPtr, aList)
    }

    /*
        Function: reveal
        Description: Returns the accumulated text string.
        Returns: String
    */
    func reveal() {
        return qalam_ink_get(pPtr)
    }
    
    /*
        Func: size
        Desc: Returns the number of characters in the ink.
        Returns: Number
    */
    func size() {
        return qalam_ink_size(pPtr)
    }

    /*
        Function: wipe
        Description: Clears the buffer for reuse.
    */
    func wipe() {
        qalam_ink_clear(pPtr)
    }

/*
    Class: QalamIndex
    Description: O(1) Hash Map for fast lookups (The Index).
*/
class QalamIndex

    pPtr = NULL

    func init {
        pPtr = qalam_index_init()
        return self
    }

    /*
        Function: define
        Description: Maps a string key to a numeric value.
        Parameters: cKey (String), nValue (Number)
    */
    func define(cKey, nValue) {
        qalam_index_set(pPtr, cKey, nValue)
    }

    /*
        Function: recall
        Description: Retrieves the value associated with a key.
        Parameters: cKey (String)
        Returns: Number (0 if not found/forgotten)
    */
    func recall(cKey) {
        return qalam_index_get(pPtr, cKey)
    }

    /*
        Func: recallKey
        Desc: Retrieves the key associated with a value.
        Parameters: nValue (Number)
        Returns: String (Empty if not found)
    */
    func recallKey(nValue) {
        return qalam_key_get(pPtr, nValue)
    }
    
    /*
        Func: knows
        Desc: Checks if a word is known (Exists in index).
              Returns 1 (True) or 0 (False).
    */
    func knows(cKey) {
        return qalam_index_exists(pPtr, cKey)
    }
    
    /*
        Func: size
        Desc: Returns the number of key-value pairs in the index.
        Returns: Number
    */
    /*
        Func: defineFromList
        Desc: Defines multiple keys from a list in one go.
        Parameters: aList (List), nValue (Number), nMinLen (Number), nTransform (Number)
    */
    func defineFromList(aList, nValue, nMinLen, nTransform) {
        qalam_index_define_from_list(pPtr, aList, nValue, nMinLen, nTransform)
    }

    /*
        Func: keys
        Desc: Returns all keys in the index as a List.
    */
    func keys() {
        return qalam_index_keys(pPtr)
    }

    /*
        Func: intersect
        Desc: Returns keys present in both this and another index.
    */
    func intersect(oOther) {
        return qalam_index_intersect(pPtr, oOther.pPtr)
    }

    /*
        Func: saveBinary
        Desc: Saves the index to a binary file.
        Parameters: cFilePath (String)
    */
    func saveBinary(cFilePath) {
        qalam_index_save_binary(pPtr, cFilePath)
    }

    /*
        Func: loadBinary
        Desc: Loads the index from a binary file.
        Parameters: cFilePath (String)
    */
    func loadBinary(cFilePath) {
        qalam_index_load_binary(pPtr, cFilePath)
    }
    
/*
    Class: QalamFormula
    Description: Compiles mathematical expressions for fast execution.
*/
class QalamFormula
    pPtr = NULL
    
    func init cExpr
        pPtr = qalam_formula_init(cExpr)
        return self
        
    func applyTo oVector
        qalam_formula_apply(pPtr, oVector.pPtr)
