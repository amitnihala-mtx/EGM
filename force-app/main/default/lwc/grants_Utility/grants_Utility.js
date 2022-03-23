import { ShowToastEvent } from 'lightning/platformShowToastEvent';

function showMessage(that, title, message, variant, mode){
    const toastEvt = new ShowToastEvent({
        title,
        message,
        variant,
        mode
    });
    that.dispatchEvent(toastEvt);
}

function getNestedAttrOut(dataArr, outerAttrName, nestedAttrObj, nestedAttrName){
    let newDataArr = [];
    for(let cnt = 0; cnt < dataArr.length; cnt++){
        let arrEle = Object.assign({}, dataArr[cnt]);
        if(arrEle.hasOwnProperty(nestedAttrObj) && arrEle[nestedAttrObj].hasOwnProperty(nestedAttrName)){
            arrEle[outerAttrName] = arrEle[nestedAttrObj][nestedAttrName];
        }
        newDataArr.push(arrEle);
    }
    return newDataArr;
}

function refreshPage(){
    eval("$A.get('e.force:refreshView').fire();");
}

export {showMessage, getNestedAttrOut, refreshPage};