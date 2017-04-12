var itemsReady = function() {
  function onClose()
  {
    $("#items_grid").data('kendoGrid').dataSource.read();
  }

  var myWindow = $("#window").kendoWindow({
    width: "800px",
    title: "Партии",
    visible: false,
    actions: [
        "Close"
    ],
    close: onClose
  }).data('kendoWindow');
  $("#items_grid").kendoGrid({
      dataSource: {
          dataType: "json",
          transport: {
              read: "/items.json",
              destroy: {
                url: function (item) {
                  return "/items/" + item.id;
                },
                type: "DELETE"
              },
          },
          schema: {
              model: {
                  id: "id",
                  fields: {
                      name: { type: "string" },
                      in_stock: { type: "number" },
                      price: { type: "number" },
                      updated_at: {
                          type: "datetime",
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
      editable: "inline",
      pageable: true,
      columns: [
          {
              field: "name",
              title: "Название продукта",
          },
          {
              title: "Количество на складе",
              field: "in_stock"
          },
          {
              field: "price",
              title: "Цена"
          },
          {
              field: "updated_at",
              title: "Последнее обновление",
              format: "{0:dd/MM/yyyy HH:MM}",
              filterable: false
          },
          {
            command: [
            {
              text: "Партии",
              click: function (e) {
                e.preventDefault();
                var item = this.dataItem($(e.currentTarget).closest("tr"));
                $.get({
                  url: '/items/' + item.id,
                  success: function (data) {
                    myWindow.content(data);
                    myWindow.center().open();
                    reloadGrid(item);
                    myWindow.center();
                  }
                });
              }
            },
            {
              text: "Удалить",
              name: "destroy",
            },
            ]
          }
      ]
  });
}

$(itemsReady);
$( document ).on('turbolinks:load',itemsReady);
