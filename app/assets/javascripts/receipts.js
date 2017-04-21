var totalPaid = 0;
var isModalOpen = false;
var returnMode = false;
var buyMode = false;
var documentLoaded = false;
var ENTER_KEY = 13;
var PLUS_KEY = 187;
var MULTIPLY_KEY = 56;
var SLASH_KEY = 191;
function startWatch () {           //  create a loop function
  setTimeout(function () {    //  call a 3s setTimeout when the loop is called
    if(isModalOpen) {
      $('#cash_received').focus();
    }
    else {
      $('#user_interaction').focus();
    }
    startWatch();
  }, 200)
}
function getGrid()
{
  return $('#receipts_grid').data('kendoGrid');
}
function updateButtons() {
  returnMode = !buyMode;
  $('#receive_money_button').prop('disabled', !buyMode);
  $('#close_cheque_button').prop('disabled', !buyMode);
  $('#delete_button').prop('disabled', !buyMode);
  $('#return_button').prop('disabled', buyMode);
}
function clearGridAndInputs() {
  if (getGrid())
  {
    getGrid().dataSource.read();
    $('#total_sum').html('0');
    $('#total_paid').html('0');
    $('#total_return').html('0');
    $('#user_interaction').val('');
    totalPaid = 0;
    $('.errors_label').addClass('hidden');
    updateButtons();
  }
}

function recalculateReturn()
{
  var totalPrice = parseInt($('#total_sum').html());
  if (totalPrice > totalPaid)
  {
    $('#return_type').html('Недоплата');
    $('#total_return').html(totalPrice - totalPaid);
  } else {
    $('#return_type').html('Сдача');
    $('#total_return').html(totalPaid- totalPrice);
  }
}

function recalculatePrice() {
  var grid = $('#receipts_grid').data('kendoGrid');
  var totalPrice = 0;
  $(grid.dataItems()).each(function () {
    totalPrice += this.Price;
  });
  if (totalPrice)
  {
    buyMode = true;
    updateButtons();
  }
  $('#total_sum').html(totalPrice);
}

function addDataToGrid(data) {
  var grid = getGrid();
  grid.dataSource.add({
    ItemName: data.name,
    Price: data.price,
    Barcode: data.code
  });
  $('#receive_money_button').prop('disabled', false);
  $('#close_cheque_button').prop('disabled', false);
  $('#delete_button').prop('disabled', false);
  $('#return_button').prop('disabled', true);
  recalculatePrice();
  buyMode = true;
}

function addToGridByBarcode(barcode) {
  $.get({
    url: '/items/search',
    data: {
      barcode: barcode
    },
    success: addDataToGrid,
    error: addDataErrors
  });
}

function removeFromGridByBarcode(barcode) {
  var grid = getGrid();
  var items = grid.dataItems();
  $.get({
    url: '/items/search',
    data: {
      barcode: barcode,
      delete: true
    }
  });
  for (var i = items.length - 1; i >= 0; i--) {
    if (items[i].Barcode == barcode)
    {
      grid.dataSource.remove(items[i]);
      break;
    }
  }
  items = grid.dataItems();
  if (items.length == 0)
  {
    buyMode = false;
    clearGridAndInputs();
  }
}

function checkBarcodeForRemoving(barcode)
{
  if (/-/.test(barcode))
    return true;
  else
    return false;
}

function clearInput()
{
  $('#user_interaction').val('');
}

function requestMoreMoney(amount) {
  $('.errors_label').removeClass('hidden');
  $('.errors_label').html('НЕОБХОДИМО ДОПЛАТИТЬ ' + amount);
}

function addDataErrors(data) {
  $('.errors_label').removeClass('hidden');
  if (data.error == 'insufficient_amount') {
    $('.errors_label').html('ПРОДУКТ КОНЧИЛСЯ');
  } else {
    $('.errors_label').html('ЭТОГО ПРОДУКТА В БАЗЕ НЕТ');
  }
}

function setReturnProductsMode() {
  if (!buyMode) {
    $('.errors_label').removeClass('hidden');
    $('.errors_label').html('ВОЗВРАТ ПРОДУКТОВ');
    returnMode = true;
  }
}

function hideError() {
  $('.errors_label').addClass('hidden');
}

function closeReceipt()
{
  data = JSON.parse(JSON.stringify(getGrid().dataItems())); //needed for correct parse data from grid
  if (data.length)
  {
    $.post({
      url: '/receipts/close',
      data: {
        items: data,
        paid: totalPaid
      },
      success: function(data) {
        clearGridAndInputs();
        $.post({
          url: 'http://localhost:8332/printcheque',
          data: data
        });
        buyMode = false;
      },
      error: function (data) {
        errorData = data.responseJSON;
        if (errorData.reason == 'not_enough_paid')
        {
          requestMoreMoney(errorData.value);
        }
      }
    });
  }
}

function openAmountPaidModal() {
  $('#cash_modal').modal('show');
  isModalOpen = true;
  $('#cash_received').focus();
}

function closeAmountPaidModal()
{
  $('#cash_modal').modal('hide');
  isModalOpen = false;
  $('#user_interaction').focus();
}

function handleEnterPressInAmountPaidModal() {
  $('#cash_received').keyup(function(e) {
    var inputValue = $(this).val();
    if(e.which == ENTER_KEY && inputValue.length) {
      totalPaid += parseInt(inputValue);
      $('#total_paid').html(totalPaid);
      $(this).val('');
      closeAmountPaidModal();
      recalculateReturn();
    }
  });

}

function receiveMoney() {
  clearInput();
  openAmountPaidModal();
  handleEnterPressInAmountPaidModal();
}

function closeCheque() {
  if (returnMode)
  {
    clearInput();
  } else {
    clearInput();
    closeReceipt();
  }
  buyMode = false;
  returnMode = false;
}

function handleButtons()
{
  $('#delete_button').unbind('click').on('click',function() {
    $('#user_interaction').val('-');
  });
  $('#receive_money_button').unbind('click').on('click',function() {
      receiveMoney();
  });
  $('#return_button').unbind('click').on('click',function() {
    setReturnProductsMode();
  });
  $('#close_cheque_button').unbind('click').on('click',function() {
    closeCheque();
  });
}
function handleTextInput()
{
  // body...
  $('#user_interaction').unbind('keyup').keyup(function(e) {

    if(e.which == ENTER_KEY) {
      hideError();
      var barcode = $(this).val();
      var negative_price = checkBarcodeForRemoving(barcode);
      if (barcode.length)
      {
        if (negative_price)
        {
          barcode = barcode.replace('-','');
          removeFromGridByBarcode(barcode);
        } else {
          addToGridByBarcode(barcode);
        }
        clearInput();
        console.log('The barcode is: ' + barcode);
      }
    }
    else if (e.which == PLUS_KEY) {
      receiveMoney();
    }
    else if (e.which == MULTIPLY_KEY) {
      closeCheque();
    }
    else if (e.which == SLASH_KEY) {
      setReturnProductsMode();
    }
});
}
function initGrid() {
  $('#receipts_grid').kendoGrid({
    dataSource: {
      transport: {
        read: "/receipts/last_opened"
      },
      schema: {
        model: {
          fields: {
            ItemName: { type: "string" },
            Price: { type: "number" },
            Barcode: { type: "number", from: "code" }
          }
        }
      }
    },
    dataBound: recalculatePrice,
    height: 600,
    columns: [{
      field: "ItemName",
      title: "Название продукта",
      width: '70%',
      template: '<h2>#=ItemName#</h2>'
    },
    {
      field: "Price",
      title: "Цена",
      template: '<h2>#=Price#</h2>'
    }]
  });
}
var docReady = function() {
  initGrid();
  startWatch();
  handleTextInput();
  handleButtons();
  clearGridAndInputs();
};
$(docReady);
$(document).on('turbolinks:load',docReady);
