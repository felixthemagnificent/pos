var batchItem = {};
var writeOffID = 0;
function getBatchGrid()
{
  return $('#batches_grid').data('kendoGrid');
}
var batchesReady = function() {
  var myBatchesWindow = $("#batches_window").kendoWindow({
    width: "800px",
    title: "Журнал операций",
    visible: false,
    actions: [
        "Close"
    ],
    close: function() {
      getBatchGrid().dataSource.read();
    }
  }).data('kendoWindow');

  var write_off_category_list = $('#write_off_category').kendoDropDownList({
    width: 300,
    autoWidth: true,
    open: function (e) {
      var listContainer = e.sender.list.closest(".k-list-container");
      listContainer.width(listContainer.width() + kendo.support.scrollbar());
    }
  }).data('kendoDropDownList');
  $('#write_off_amount').kendoNumericTextBox({
    min: 1,
    format: "n0",
    round: true
  });

  write_off_category_list.list.width("auto");
  var myWriteOffWindow = $("#write_off_window").kendoWindow({
    width: "400px",
    title: "Списание",
    visible: false,
    actions: [
        "Close"
    ],
    close: function() {
      getBatchGrid().dataSource.read();
    }
  }).data('kendoWindow');
  var searchProductWindow = $("#search_product_window").kendoWindow({
    width: "800px",
    title: "Продукты",
    visible: false,
    actions: [
        "Close"
    ],
    close: function() {
      getBatchGrid().dataSource.read();
    }
  }).data('kendoWindow');
  $('#make_write_off').unbind('click').on('click',function() {
    $.post({
      url: '/batches/' + writeOffID +'/writeoff',
      data: {
        reason: $("#write_off_category").data('kendoDropDownList').value(),
        amount: $("#write_off_amount").data('kendoNumericTextBox').value(),
      },
      success: function(data) {
        writeOffID = 0;
        myWriteOffWindow.close();
        getBatchGrid().dataSource.read();
        $("#write_off_amount").data('kendoNumericTextBox').value(1);
      }
    });
  });
  $('#add_batch-button').unbind('click').click(function() {
    $('#batch_amount').val('');
    $('#batch_amount').prop('disabled',true);
    $('#batch_barcode').val('');
    $('#batch_price').prop('disabled',true);
    $('#batch_price').val('');
    $('#batch_product_name').html('');
    $('#find_product_open_window').addClass('hidden');
    $('#new_batch-window').modal('show');
  });
  $('#new_batch-window').on('shown.bs.modal', function() {
    $(document).off('focusin.modal');
  });
  $('#save_batch').unbind('click').click(function() {
    $.post({
      url: '/batches.json',
      data: {
        item_id: batchItem.id,
        amount: $('#batch_amount').val(),
        price: $('#batch_price').val(),
        barcode: $('#batch_barcode').val(),
      },
      success: function(data) {
        $('#new_batch-window').modal('hide');
        $('#batch_amount').val('');
        $('#batch_amount').prop('disabled',true);
        $('#batch_barcode').val('');
        $('#batch_price').prop('disabled',true);
        $('#batch_price').val('');
        $('#batch_product_name').html('');
        $('#find_product_open_window').addClass('hidden');
        getBatchGrid().dataSource.read();
      },
    })
  });
  $('#batches_window_product_search').unbind('keyup').keyup(function(e) {
    var product_name = this.value;
    $('#search_product_window-grid').data('kendoGrid').dataSource.filter({field: 'name', operator: "contains", value: product_name});
  });

  $('#batches-main_product_search').unbind('keyup').keyup(function(e) {
    var product_name = this.value;
    if (e.which == ESC_KEY)
    {
      this.value = '';
      product_name = '';
    }
    $('#batches_grid').data('kendoGrid').dataSource.filter({field: 'name', operator: "contains", value: product_name});

  });

  $('#find_product_open_window-button').unbind('click').on('click',function() {
    searchProductWindow.center().open();
    $('#batches_grid').data('kendoGrid').dataSource.read();
  });
  $('#batch_barcode').unbind('keyup').keyup(function(e) {
    if(e.which == ENTER_KEY) {
      var barcode = $(this).val();
       $.get({
        url: '/items/search',
        data: {
          barcode: barcode
        },
        success: function(data) {
          var name = data.name;
          batchItem = data;
          $('#batch_product_name').html(name);
          $('#batch_amount').prop('disabled',false);
          $('#batch_price').prop('disabled',false);
          $('#find_product_open_window').addClass('hidden');
        },
        error: function (data) {
          $('#batch_product_name').html('');
          $('#find_product_open_window').removeClass('hidden');
        }
      });
    }
  });
  $('#search_product_window-grid').kendoGrid({
      dataSource: {
          dataType: "json",
          transport: {
              read: "/items/list",
          },

          schema: {
              data: "data",
              total: "total",
              model: {
                  // id: "id",
                  fields: {
                      name: { type: "string" },
                  }
              }
          },
          pageSize: 20,
          serverPaging: true,
          serverFiltering: true,
          serverSorting: true
      },
      height: 550,
      sortable: true,
      pageable: true,
      selectable: true,
      columns: [{ field: "name", title: "Название продукта" }],
      change: function(e) {
        var selectedRow = this.select();
        var selectedDataItem = this.dataItem(selectedRow);
        console.log(selectedDataItem);
        $.post({
          url: '/items/addbarcode',
          data: {
            item_id: selectedDataItem.item_id,
            barcode: $('#batch_barcode').val()
          },
          success: function(data) {
            searchProductWindow.close();
            $('#batch_product_name').html(selectedDataItem.name);
            $('#find_product_open_window').addClass('hidden');
            $('#batch_amount').prop('disabled',false);
            $('#batch_price').prop('disabled',false);
            batchItem.id = selectedDataItem.item_id;
          }
        })
      }
  });
  $("#batches_grid").kendoGrid({
      dataSource: {
          dataType: "json",

          transport: {
              read: "/batches.json",
              update: {
                url: function (item) {
                  return "/batches/" + item.id;
                },
                type: "PATCH"
              },
              destroy: {
                url: function (item) {
                  return "/batches/" + item.id + ".json";
                },
                type: "DELETE"
              },
          },
          schema: {
              data: "data",
              total: "total",
              model: {
                  id: "id",
                  fields: {
                      name: { type: "string" },
                      in_stock: { type: "number", editable: false },
                      price: { type: "number" },
                      updated_at: {
                          type: "datetime",
                          editable: false,
                          parse: function(date) {
                              return kendo.parseDate(date)
                          },
                      }

                  }
              }
          },
          pageSize: 20,
          serverPaging: true,
          serverFiltering: true,
          serverSorting: true
      },
      height: 550,
      filterable: {
          extra: false,
          messages: {
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
      sortable: true,
      editable: {
        mode: "inline",
        confirmation:  "Вы правда хотите удалить продукт?"
      },
      pageable: true,
      columns: [
          {
              field: "name",
              title: "Название продукта",
          },
          {
              field: "price",
              title: "Цена",
          },
          {
              field: "amount",
              title: "Количество",
          },
          {
            command: [
            {
              text: "Журнал операций",
              click: function (e) {
                e.preventDefault();
                var batch = getBatchGrid().dataItem($(e.currentTarget).closest("tr"));
                $.get({
                  url: '/batches/' + batch.id + '/journal',
                  success: function (data) {
                    myBatchesWindow.content(data);
                    myBatchesWindow.center().open();
                    myBatchesWindow.center();
                    reloadGrid(batch.id);
                  }
                });
              }
            },
            {
              text: "Списание",
              click: function (e) {
                e.preventDefault();
                var batch = getBatchGrid().dataItem($(e.currentTarget).closest("tr"));
                writeOffID = batch.id;
                myWriteOffWindow.center().open();
                // $.get({
                //   url: '/batches/' + batch.id + '/journal',
                //   success: function (data) {
                //     myBatchesWindow.content(data);
                //     myBatchesWindow.center().open();
                //     myBatchesWindow.center();
                //     reloadGrid(batch.id);
                //   }
                // });
              }
            },
            ],
            width: '24%'
          }
      ]
  });
}

$( document ).on('ready turbolinks:load',function () {
  if ($('#batches_grid').length)
  {
    batchesReady();
  }
});

