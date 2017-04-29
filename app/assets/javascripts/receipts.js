var totalPaid = 0;
var isModalOpen = false;
var receiptOpened = false;
var documentLoaded = false;
var ENTER_KEY = 13;
var ESC_KEY = 27;
var PLUS_KEY = 187;
var MULTIPLY_KEY = 56;
var SLASH_KEY = 191;
function startWatch () {           //  create a loop function
  setTimeout(function () {    //  call a 3s setTimeout when the loop is called
    if(isModalOpen) {
      //$('#cash_received').focus();
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
function updateGrid()
{
  getGrid().dataSource.read();
}
function updateButtons()
{
  $('#receive_money_button').prop('disabled', !receiptOpened);
  $('#close_cheque_button').prop('disabled', !receiptOpened);
  $('#delete_button').prop('disabled', !receiptOpened);
  $('#return_button').prop('disabled', receiptOpened);
}
function clearGridAndInputs()
{
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

function recalculatePrice()
{
  var grid = $('#receipts_grid').data('kendoGrid');
  var totalPrice = 0;
  $(grid.dataItems()).each(function () {
    totalPrice += this.Price * this.Amount;
  });
  if (totalPrice)
  {
    receiptOpened = true;
    updateButtons();
  }
  $('#total_sum').html(totalPrice);
}
function findBarcodeInGrid(barcode)
{
  var items = getGrid().dataItems();
  for (var i = items.length - 1; i >= 0; i--) {
    if (items[i].Barcode == barcode)
    {
      return items[i];
    }
  }
  return false;
}
function addDataToGrid(data)
{
  var grid = getGrid();
  var item = findBarcodeInGrid(data.code)
  // if (item)
  // {
  //   item.Quantity++;
  // } else {
  //   grid.dataSource.add({
  //     ItemName: data.name,
  //     Price: data.price,
  //     Barcode: data.code,
  //     Quantity: 1
  //   });
  // }
  updateGrid();
  $('#receive_money_button').prop('disabled', false);
  $('#close_cheque_button').prop('disabled', false);
  $('#delete_button').prop('disabled', false);
  $('#return_button').prop('disabled', true);
  recalculatePrice();
  receiptOpened = true;
}

function addToGridByBarcode(barcode)
{
  $.get({
    url: '/items/process_cheque',
    data: {
      barcode: barcode
    },
    success: addDataToGrid,
    error: addDataErrors
  });
}

function removeFromGridByBarcode(barcode)
{
  var grid = getGrid();
  var items = grid.dataItems();
  $.get({
    url: '/items/process_cheque',
    data: {
      barcode: barcode,
      delete: true
    },
    success: function() {
      updateGrid();
      items = grid.dataItems();
      if (items.length == 0)
      {
        receiptOpened = false;
        clearGridAndInputs();
      }
    }
  });
  // for (var i = items.length - 1; i >= 0; i--) {
  //   if (items[i].Barcode == barcode)
  //   {
  //     grid.dataSource.remove(items[i]);
  //     break;
  //   }
  // }
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

function requestMoreMoney(amount)
{
  $('.errors_label').removeClass('hidden');
  $('.errors_label').html('НЕОБХОДИМО ДОПЛАТИТЬ ' + amount);
}

function addDataErrors(data)
{
  $('.errors_label').removeClass('hidden');
  if (data.error == 'insufficient_amount') {
    $('.errors_label').html('ПРОДУКТ КОНЧИЛСЯ');
  } else {
    $('.errors_label').html('ЭТОГО ПРОДУКТА В БАЗЕ НЕТ');
  }
}

function hideError()
{
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
        receiptOpened = false;
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

function openAmountPaidModal()
{
  $('#cash_modal').on('shown.bs.modal', function () {
    $('#cash_received').focus();
    $('#cash_received').val('');
  });
  $('#cash_modal').modal('show');
  isModalOpen = true;
}

function closeAmountPaidModal()
{
  $('#cash_modal').modal('hide');
  $('#cash_modal').unbind('shown.bs.modal');
  isModalOpen = false;
  $('#user_interaction').focus();
}

function handleEnterPressInAmountPaidModal()
{
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

function receiveMoney()
{
  clearInput();
  openAmountPaidModal();
  handleEnterPressInAmountPaidModal();
}

function closeCheque()
{
  clearInput();
  closeReceipt();
  receiptOpened = false;
}

function clearCheque()
{
  $.post({
    url: '/receipts/clear',
    type: "POST",
    success: function(e) {
      getGrid().dataSource.read();
      $('#user_interaction').val('');
      receiptOpened = false;
      updateButtons();
    }
  });
}
function handleReturnModal()
{
  $('#return_modal').on('shown.bs.modal', function () {
    $('#receipt_id').focus();
    $('#receipt_id').val('');
  });
  $('#return_modal').on('hide.bs.modal', function () {
    $('#receipt_id').focus();
    $('#receipt_id').val('');
    $('#return_table > tbody').html('');
  });
  $('#receipt_id').on('keyup',function(e) {
    var receiptId = $(this).val();
    if(e.which == ENTER_KEY && receiptId.length) {
      $.get({
        url: '/receipts/' + receiptId + '.json',
        success: function(data) {
          for (var i = 0; i < data.length; i++) {
            var row_data = data[i];
            $('#return_table > tbody').append("<tr><td>" + row_data.name + "</td><td><input type='text' id='row_"+i+"_quantity' value='0' data-position-id='" + row_data.position_id + "'/></td></tr>");
            $("#row_"+i+"_quantity").kendoNumericTextBox({
              min:0,
              max: row_data.amount,
              format: "n0"
            })
          }
        }
      })
    }
  });
  $('#submit_return').on('click',function() {
    var tdArray = [];
    $("#return_table tbody tr").each(function() {
      if ($(this).find("input[type='text']"))
      {
      tdArray.push({amount: $(this).find("input[type='text']").val(), position_id: $(this).find(":hidden").data('position-id')});
      }
    });
    $.post({
      url: '/returns',
      data: {
        items: tdArray,
        receipt_id: $('#receipt_id').val(),
      },
      success: function(data) {
        $('#return_modal').modal('hide');
        $.post({
          url: 'http://localhost:8332/printcheque',
          data: data
        });
      }
    });
  });
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
    isModalOpen = true;
    $('#return_modal').modal('show');
  });
  $('#close_cheque_button').unbind('click').on('click',function() {
    closeCheque();
  });
  $('#clear_receipt').on('click',clearCheque);
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
      clearCheque();
    }
  });
}
function detailInit(e) {
  var detailRow = e.detailRow;
  var detailRowGrid;
  //element.data('kendoGrid').expandRow(e.detailRow);
  //rows.push(e);
  detailRow.find(".tabstrip").kendoTabStrip({
      animation: {
          open: { effects: "fadeIn" }
      }
  });

  detailRowGrid = detailRow.find("#receipt_details_grid").kendoGrid({
      dataSource: {
        transport: {
          read:  {
            url: "/receipts/" + e.data.id + ".json",
          },
        },
        schema: {
            model: {
                id: "id",
                fields: {
                    name: { type: "string" },
                    price: { type: "integer" },
                    amount: { type: "integer" },
                }
            }
        }
      },
      dataBound: function() {
        var new_height = $('#receipt_details_grid').getKendoGrid().content.height() + $('#receipt_details_grid').getKendoGrid().wrapper.height();
      },
      //height: 400,
      columns: [
          {
              field: "name",
              title: "Продукт",
          },
          {
              field: "amount",
              title: "Количество",
              filterable: false,
              encoded: false,
              width: '20%'
          },
          {
              title: "Цена",
              field: "price",
              width: '15%'
          },
        ]
      });
}
function initAllReceiptsGrid()
{
  if ($('#all_receipts_grid').length)
  {
    var all_receipts_grid = $("#all_receipts_grid").kendoGrid({
      dataSource: {
          type: "jsonp",
          transport: {
              read: "/reports/all_receipts.json"
          },
          schema: {
              data: "data",
              total: "total",
              model: {
                  fields: {
                      id: { type: "integer" },
                      created_at: { type: "datetime",
                      parse: function(date) {
                             return kendo.parseDate(date)
                          },
                      },
                      price: { type: "integer" },
                      profit: { type: "integer" }

                  }
              }
          },
          pageSize: 10,
          serverPaging: true,
          serverFiltering: true,
          //serverSorting: true
      },
      //height: 350,
      filterable: {
          extra: false,
          messages: {
            and: "И",
            or: "Или",
            info: "Фильтр: ",
            clear: "Очистить",
            filter: "ОК"
          },
          operators: {
              number:{
                  eq: "Равно",
                  gte: "Больше или равно",
                  gt: "Больше",
                  lte: "Меньше или равно",
                  lt: "Меньше"
              },
              datetime: {
                  gte: "После или равно",
                  gt: "После",
                  lte: "До или равно",
                  lt: "До"
              }
          }
      },
      // toolbar: ["excel"],
      // excel: {
      //     allPages: true
      // },
      sortable: true,
      detailTemplate: kendo.template($("#template").html()),
      detailInit: detailInit,
      detailExpand: function(e) {
        this.collapseRow(this.tbody.find(' > tr.k-master-row').not(e.masterRow));
      },
      pageable: true,
      scrollable: true,
      columns: [
          {
              field: "id",
              title: "Номер чека"
          },
          {
              field: "created_at",
              title: "Чек закрыт",
              filterable: {
                extra: true,
                ui: function(element) {
                  element.kendoDateTimePicker({
                    format: "yyyy/MM/dd hh:mm"
                  }); // initialize a Kendo UI DateTimePicker
                }
              }
          },
          {
              field: "income",
              title: "Cумма чека",
              filterable: false,
              encoded: false
          },
          {
              field: "profit",
              title: "Прибыль",
              filterable: false,
              encoded: false
          },
      ]
    });
  }
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
            Barcode: { type: "number", from: "code" },
            Amount: { type: "number" },
          }
        }
      }
    },
    dataBound: recalculatePrice,

    height: 630,
    columns: [{
      field: "ItemName",
      title: "Название продукта",
      width: '70%',
      template: '<h2>#=ItemName#</h2>'
    },
    {
      field: "Amount",
      title: "Количество",
      template: '<h2>#=Amount#</h2>'
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
  initAllReceiptsGrid();
  handleReturnModal();
};
$(docReady);
