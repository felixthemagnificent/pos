var batchItem;
function getBatchGrid()
{
  return $('#batches_grid').data('kendoGrid');
}
var batchesReady = function() {
  var myBatchesWindow = $("#batches_window").kendoWindow({
    width: "800px",
    title: "Партии",
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
  $('#find_product_open_window-button').unbind('click').on('click',function() {
    searchProductWindow.center().open();
    $('#search_product_window-grid').data('kendoGrid').dataSource.read();
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
              text: "Партии",
              click: function (e) {
                e.preventDefault();
                var batch = getBatchGrid().dataItem($(e.currentTarget).closest("tr"));
                $.get({
                  url: '/batches/' + batch.item_id,
                  success: function (data) {
                    myBatchesWindow.content(data);
                    myBatchesWindow.center().open();
                    myBatchesWindow.center();
                    reloadGrid(batch.item_id);
                  }
                });
              }
            },
            ],
            width: '24%'
          }
      ]
  });
}
$( document ).on('ready turbolinks:load',batchesReady);

