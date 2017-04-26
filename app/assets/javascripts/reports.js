var reportsReadyFunction = function() {
  var receiptDetailsWindow = $("#receipt_detail_window").kendoWindow({
    width: "400px",
    title: "Чек",
    visible: false
  }).data('kendoWindow');

  var mean_receipts_grid = $("#mean_receipts_grid").kendoGrid({
      dataSource: {
          type: "jsonp",
          transport: {
              read: "/reports/mean_receipts.json"
          },
          schema: {
              data: "data",
              total: "total",
              model: {
                  fields: {
                      created_at: { type: "date",
                      parse: function(date) {
                             return kendo.parseDate(date)
                          },
                      },
                      price: { type: "integer" },
                      count: { type: "integer" }

                  }
              }
          },
          pageSize: 10,
          serverPaging: false,
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
      toolbar: ["excel"],
      excel: {
          allPages: true
      },
      sortable: true,
      pageable: true,
      scrollable: true,
      //filtermenu:filterMenuInit,
      columns: [{
              field: "created_at",
              title: "День",
              filterable: false
          },
          {
              field: "price",
              title: "Цена",
              filterable: false,
              encoded: false
          },
          {
              field: "count",
              title: "Чеков",
              filterable: false,
              encoded: false
          },

      ]
  });
  var total_sum_receipts_grid = $("#total_sum_receipts_grid").kendoGrid({
      dataSource: {
          type: "jsonp",
          transport: {
              read: "/reports/total_sum_receipts.json"
          },
          schema: {
              data: "data",
              total: "total",
              model: {
                  fields: {
                      created_at: { type: "date",
                      parse: function(date) {
                             return kendo.parseDate(date)
                          },
                      },
                      count: { type: "integer" },
                      price: { type: "integer" }

                  }
              }
          },
          pageSize: 10,
          serverPaging: false,
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
      toolbar: ["excel"],
      excel: {
          allPages: true
      },
      sortable: true,
      pageable: true,
      scrollable: true,
      //filtermenu:filterMenuInit,
      columns: [{
              field: "created_at",
              title: "День",
              filterable: false
          },
          {
              field: "price",
              title: "Выручка",
              filterable: false,
              encoded: false
          },
          {
              field: "count",
              title: "Чеков",
              filterable: false,
              encoded: false
          },
      ]
  });
  var popular_products_grid = $("#popular_products_grid").kendoGrid({
      dataSource: {
          type: "jsonp",
          transport: {
              read: "/reports/popular_products.json"
          },
          schema: {
              data: "data",
              total: "total",
              model: {
                  fields: {
                      place: { type: "integer" },
                      product: { type: "string" },
                      price: { type: "integer" },
                      selled: {type: "string"},
                  }
              }
          },
          pageSize: 10,
          serverPaging: false,
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
      toolbar: ["excel"],
      excel: {
          allPages: true
      },
      sortable: true,
      pageable: true,
      scrollable: true,
      //filtermenu:filterMenuInit,
      columns: [{
              field: "place",
              title: "Место",
              filterable: false,
              width: '6%'
          },
          {
              field: "selled",
              title: "Продано на сумму",
              filterable: false,
              encoded: false
          },
          {
              field: "product",
              title: "Продукт",
              filterable: false,
              encoded: false
          },
          {
              field: "count",
              title: "Количество продаж",
              filterable: false,
              encoded: false
          },
      ]
  });
  var total_products_grid = $("#total_products_grid").kendoGrid({
      dataSource: {
          dataType: "json",
          transport: {
              read: "/reports/total_products.json"
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
      toolbar: ["excel"],
      excel: {
          allPages: true
      },
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
          // {
          //   command: [
          //   {
          //     text: "Партии",
          //     click: function (e) {
          //       e.preventDefault();
          //       var batch = getBatchGrid().dataItem($(e.currentTarget).closest("tr"));
          //       $.get({
          //         url: '/batches/' + batch.item_id,
          //         success: function (data) {
          //           myBatchesWindow.content(data);
          //           myBatchesWindow.center().open();
          //           myBatchesWindow.center();
          //           reloadGrid(batch.item_id);
          //         }
          //       });
          //     }
          //   },
          //   ],
          //   width: '24%'
          // }
      ]
  });
}

var reportsReady = function () {
  if (!$('#all_receipts_grid').data('kendoGrid'))
  {
    reportsReadyFunction();
  }
}

$(reportsReady);
$( document ).on('turbolinks:load',reportsReady);
