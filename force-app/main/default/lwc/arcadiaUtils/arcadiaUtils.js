import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//show toast message on the page
const showToast = (page, title, message, variant) => {
    let modeValue = variant === 'error' || variant === 'warning' ? 'sticky' : 'dismissible';
    const toastEvent = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: modeValue
    });
    page.dispatchEvent(toastEvent);
};

//format string with merge fields based on the arguments passed
//first parameter the string we need to format that contains merge fields {0} and so on
//second parameter is the list of values to use to fill the merge fields in the string
const formatString = (stringToFormat, ...formattingArguments) => {
    if (typeof stringToFormat !== 'string') throw new Error("'stringToFormat' must be a String");
    return stringToFormat.replace(/{(\d+)}/gm, (match, index) =>
        formattingArguments[index] === undefined ? '' : `${formattingArguments[index]}`
    );
};

/**
 * Normalize the given error object.
 * @param  {Error | Object} Either a javascript Error or an error emitted from LDS (ErrorResponse).
 * @return {String} A string error message
 */
const parseErrorMessage = error => {
    let errorMsg = 'Unknown Error';

    if (typeof error === 'string') {
        errorMsg = error;
    } else if (error.message && typeof error.message === 'string') {
        errorMsg = error.message;
    } else if (Array.isArray(error.body) && error.body.length > 0) {
        errorMsg = error.body.map(e => e.message).join(', ');
    } else if (error.body && typeof error.body.message === 'string') {
        errorMsg = error.body.message;
    }

    return errorMsg;
};

//Utility to convert the CSV file content to an array
const csvToArray = (str, delimiter = ',') => {
    // slice from start of text to the first \n index
    // use split to create an array from string by delimiter
    const headers = str.slice(0, str.indexOf('\n')).split(delimiter);

    // slice from \n index + 1 to the end of the text
    // use split to create an array of each csv value row
    const rows = str.slice(str.indexOf('\n') + 1).split('\n');

    // Map the rows
    // split values from each row into an array
    // use headers.reduce to create an object
    // object properties derived from headers:values
    // the object passed as an element of the array
    const arr = rows.map(function (row) {
        const values = row.split(delimiter);
        const el = headers.reduce(function (object, header, index) {
            let headerVal = header.replace(/\s+/g, '');
            if (values[index]) {
                object[headerVal] = values[index].replace(/\r+/g, '');
            }
            if (object[headerVal] == '') {
                object[headerVal] = null;
            }
            return object;
        }, {});
        return el;
    });

    // return the array
    return arr;
};

//utility to export data into CSV and download it to the user
const exportCSVFile = (fileData, fileName) => {
    let rowEnd = '\n';
    let csvString = '';

    // getting keys from data
    let rowData = new Set();
    fileData.forEach(function (record) {
        Object.keys(record).forEach(function (key) {
            rowData.add(key);
        });
    });

    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    rowData = Array.from(rowData);

    // splitting using ',' --> Forming the header row
    csvString += rowData.join(',');
    csvString += rowEnd;

    // main for loop to get the data based on key value and forming for each element in the array a row in the csv file
    for (let i = 0; i < fileData.length; i++) {
        let colValue = 0;

        // validating keys in data
        for (let key in rowData) {
            if (rowData.hasOwnProperty(key)) {
                // Key value
                // Ex: Id, Name
                let rowKey = rowData[key];
                // add , after every value except the first.
                if (colValue > 0) {
                    csvString += ',';
                }
                // If the column is undefined, it as blank in the CSV file.
                let value = fileData[i][rowKey] === undefined ? '' : fileData[i][rowKey];
                csvString += '"' + value + '"';
                colValue++;
            }
        }
        csvString += rowEnd;
    }

    // Creating anchor element to download
    let downloadElement = document.createElement('a');

    // The  encodeURI encodes special characters, except: , / ? : @ & = + $ # so we Used encodeURIComponent() to encode these special characters.
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    downloadElement.download = fileName ? fileName + '.csv' : 'export.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
    document.body.removeChild(downloadElement);
};

// utility to convert base64 data to blob
const b64toBlob = (b64Data, contentType) => {
    const sliceSize = 512;
    const byteCharacters = atob(b64Data);
    const byteArrays = [];
    for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        const slice = byteCharacters.slice(offset, offset + sliceSize);
        const byteNumbers = new Array(slice.length);
        for (let i = 0; i < slice.length; i++) {
            byteNumbers[i] = slice.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
    }
    const fileBlob = new Blob(byteArrays, { type: contentType });
    return fileBlob;
};

export { showToast, formatString, parseErrorMessage, exportCSVFile, csvToArray, b64toBlob };
