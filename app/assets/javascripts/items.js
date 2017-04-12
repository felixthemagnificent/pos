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
              create: {
                url: "/items.json",
                type: "POST"
              },
              update: {
                url: function (item) {
                  return "/items/" + item.id;
                },
                type: "PATCH"
              },
              destroy: {
                url: function (item) {
                  return "/items/" + item.id + ".json";
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
      toolbar: [{ name: "create", text: "Добавить" }],
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
              title: "Количество на складе",
              field: "in_stock",
              editable: false,
              width: '15%'
          },
          {
              field: "price",
              title: "Цена",
              width: '15%'
          },
          {
              field: "updated_at",
              title: "Последнее обновление",
              format: "{0:dd/MM/yyyy HH:MM}",
              filterable: false,
              editable: false,
              width: '13%'
          },
          {
            command: [
            {
              text: { // sets the text of the "Edit", "Update" and "Cancel" buttons
                    edit: "Изменить",
                    update: "Сохранить",
                    cancel: "Отмена"
                },
              name: "edit",
            },
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
                    myWindow.center();
                    reloadGrid(item);
                  }
                });
              }
            },
            {
              text: "Удалить",
              name: "destroy",
            },
            ],
            width: '24%'
          }
      ]
  });
}

$(itemsReady);
$( document ).on('turbolinks:load',itemsReady);
