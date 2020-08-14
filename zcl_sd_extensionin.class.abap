class zcl_sd_extensionin definition
  public
  final
  create public .

  public section.

    class-data c_insert type updkz_d value 'I' ##NO_TEXT.

    class-methods add_value
      importing
        !item_field  type fieldname
        !item_value  type posnr
        !field       type fieldname
        !structure   type tabname
        !value       type any
      changing
        !extensionin type bapiparex_tab .

  protected section.

    class-methods fill
      importing
        !value           type any
      returning
        value(container) type bapiparex-valuepart1 .

    class-methods read
      importing
        !container   type bapiparex-valuepart1
      exporting
        value(value) type any .

  private section.

    class-methods get_pargb
      importing
        !vbeln       type any
      returning
        value(pargb) type bseg-pargb .

    class-methods add
      importing
        !item_field  type fieldname
        !item_value  type posnr
        !field       type fieldname
        !structure   type tabname
        !value       type any
      changing
        !extensionin type bapiparex_tab .

    class-methods change
      importing
        !item_field   type fieldname
        !item_value   type posnr
        !field        type fieldname
        !structure    type tabname
        !value        type any
        !line_change  type sy-tabix
        !line_changex type sy-tabix
      changing
        !extensionin  type bapiparex_tab .

    class-methods change_item
      importing
        !field type fieldname
        !value type any
      changing
        !data  type ref to data .

    class-methods fill_item
      importing
        !item_field type fieldname
        !item_value type posnr
        !field      type fieldname
        !value      type any
      changing
        line        type ref to data
        linex       type ref to data .

    class-methods check_item
      importing
        !item         type bape_vbap-posnr
        !structure    type tabname
        !extensionin  type bapiparex_tab
      exporting
        !line_change  type sy-tabix
        !line_changex type sy-tabix .

    class-methods get_line_change
      importing
        !item            type bape_vbap-posnr
        !extensionin     type bapiparex_tab
        value(structure) type bapiparex-structure
      returning
        value(line)      type sy-tabix .

    class-methods read_vbap
      importing
        !container   type bapiparex-valuepart1
      returning
        value(value) type bape_vbap .

    class-methods read_vbapx
      importing
        !container   type bapiparex-valuepart1
      returning
        value(value) type bape_vbapx .

endclass.


class zcl_sd_extensionin implementation.

  method add_value .

    data:
      line_change  type sy-tabix,
      line_changex type sy-tabix.


*   Verificando se o item ja foi adicionado na EXTENSIONIN
    zcl_sd_extensionin=>check_item(
      exporting
        item         = item_value
        structure    = structure
        extensionin  = extensionin
      importing
        line_change  = line_change
        line_changex = line_changex
    ).

*   Se existir a linha a ser alterada, senao retornara a
*   posicao da linha encontrada (ou zero se caso nao existir)
    if ( line_change eq 0 ) .

*     Inserir novo registro referente ao item informado
      zcl_sd_extensionin=>add(
        exporting
          item_value  = item_value
          item_field  = item_field
          field       = field
          structure   = structure
          value       = value
        changing
          extensionin = extensionin
      ) .

    else .

*     Alterar item que ja foi adicionado na EXTENSIONIN
      zcl_sd_extensionin=>change(
        exporting
          item_field   = item_field
          item_value   = item_value
          field        = field
          structure    = structure
          value        = value
          line_change  = line_change
          line_changex = line_changex
        changing
          extensionin = extensionin
      ) .

    endif .

  endmethod.


  method add.

    data:
      line_extensionin type bapiparex,

      structurex       type tabname,
      line             type ref to data,
      linex            type ref to data.

    field-symbols:
      <line>   type any,
      <linex>  type any,
      <field>  type any,
      <fieldx> type any.


    if ( item_field is not initial ) and
       ( item_value is not initial ) and
       ( field      is not initial ) and
       ( structure  is not initial ) and
       ( value      is not initial ) .

      create data line type (structure) .

      structurex = |{ structure }X| .
      create data linex type (structurex) .

      zcl_sd_extensionin=>fill_item(
         exporting
           item_field  = item_field
           item_value  = item_value
           field       = field
           value       = value
         changing
           line        = line
           linex       = linex
      ).

    endif .


    assign line->* to <line> .
    assign linex->* to <linex> .


    if ( <line>  is assigned ) and
       ( <linex> is assigned )  .

      line_extensionin-structure = structure .

      call method cl_abap_container_utilities=>fill_container_c
        exporting
          im_value               = <line>
        importing
          ex_container           = line_extensionin-valuepart1
        exceptions
          illegal_parameter_type = 1
          others                 = 2.

      if ( sy-subrc eq 0 ) .

        append line_extensionin to extensionin .
        clear line_extensionin .

        line_extensionin-structure  = structurex .
        line_extensionin-valuepart1 = <linex> .

        append line_extensionin to extensionin .
        clear line_extensionin .

      else .
      endif.

    endif .


    free:
      line_extensionin, structurex, line, linex .

    unassign:
      <line>, <linex>, <field>, <fieldx> .


  endmethod.


  method change.

    data:
      line_extensionin type bapiparex,
      structurex       type tabname,
      line             type ref to data,
      linex            type ref to data.

    field-symbols:
      <line>             type any,
      <linex>            type any,
      <field>            type any,
      <fieldx>           type any,
      <line_extensionin> type bapiparex.


    if ( item_field is not initial ) and
       ( item_value is not initial ) and
       ( field      is not initial ) and
       ( structure  is not initial ) and
       ( value      is not initial ) .

      create data line type (structure) .

      structurex = |{ structure }X| .
      create data linex type (structurex) .

    endif .


    assign line->* to <line> .
    assign linex->* to <linex> .

    read table extensionin assigning <line_extensionin>
         index line_change .

    if ( sy-subrc eq 0 ) and
       ( <line> is assigned ) .


      zcl_sd_extensionin=>read(
        exporting
          container = <line_extensionin>-valuepart1
        importing
          value     = <line>
      ).

      zcl_sd_extensionin=>change_item(
        exporting
          field  = field
          value  = value
        changing
          data   = line
      ) .


      <line_extensionin>-valuepart1 = zcl_sd_extensionin=>fill( <line> ) .

    endif .


    unassign:
      <line_extensionin> .

    read table extensionin
     assigning <line_extensionin>
         index line_changex .


    if ( sy-subrc eq 0 ) and
       ( <linex> is assigned ) .


      zcl_sd_extensionin=>read(
        exporting
          container = <line_extensionin>-valuepart1
        importing
          value     = <linex>
      ).

      zcl_sd_extensionin=>change_item(
        exporting
          field  = field
          value  = abap_true
        changing
          data   = linex
      ) .

      <line_extensionin>-valuepart1 = zcl_sd_extensionin=>fill( <linex> ) .

    endif .

  endmethod.


  method change_item .


    field-symbols:
      <data>  type any,
      <field> type any.


    if ( data is not initial ) .

      assign data->* to <data> .

      if ( <data> is assigned ) .

        assign component field of structure <data> to <field> .
        if ( <field> is assigned ) .

          <field> = value .

        endif .

      endif .

    endif .

    unassign:
      <data>, <field> .


  endmethod .


  method fill_item .

    if ( line is not initial ) .

      zcl_sd_extensionin=>change_item(
        exporting
          field  = item_field
          value  = item_value
        changing
          data   = line
      ) .

      zcl_sd_extensionin=>change_item(
        exporting
          field  = field
          value  = value
        changing
          data   = line
      ) .

    endif .


    if ( linex is not initial ) .

      zcl_sd_extensionin=>change_item(
        exporting
          field  = item_field
          value  = item_value
        changing
          data   = linex
      ) .

      zcl_sd_extensionin=>change_item(
        exporting
          field  = field
          value  = abap_true
        changing
          data   = linex
      ) .

    endif .

  endmethod .


  method check_item .

    data:
      structurex type te_struc .

    if ( structure is not initial ) .
      structurex = |{ structure }X| .
    endif .

    if ( lines( extensionin )  eq 0 ) .

    else .

      line_change =
        zcl_sd_extensionin=>get_line_change(
          item        = item
          extensionin = extensionin
*         structure   = 'BAPE_VBAP'
          structure   = structure
        ).

      line_changex =
        zcl_sd_extensionin=>get_line_change(
          item        = item
          extensionin = extensionin
*         structure   = 'BAPE_VBAPX'
          structure   = structurex
        ).


    endif .

    free structurex .

  endmethod .


  method fill.

    if ( value is not initial ) .

      call method cl_abap_container_utilities=>fill_container_c
        exporting
          im_value               = value
        importing
          ex_container           = container
        exceptions
          illegal_parameter_type = 1
          others                 = 2.

      if ( sy-subrc eq 0 ) .
      else .
        clear container .
      endif .

    endif .

  endmethod.


  method get_line_change.

    data:
      bape_vbap  type bape_vbap .

    if ( lines( extensionin )  eq 0 ) .

    else .

      loop at extensionin assigning field-symbol(<line_extensionin>)
        where structure eq structure .

        data(line_tabix) = sy-tabix .

        call method cl_abap_container_utilities=>read_container_c
          exporting
            im_container           = <line_extensionin>-valuepart1
          importing
            ex_value               = bape_vbap
          exceptions
            illegal_parameter_type = 1
            others                 = 2.

        if ( sy-subrc eq 0 ) .

          if ( bape_vbap-posnr eq item ) .

            line = line_tabix .
            exit .

          endif .

        endif.

      endloop .

    endif .

  endmethod.


  method get_pargb.

    data:
      vbeln_convert type vbap-vbeln,
      abgru         type vbap-abgru.

    if ( vbeln is not initial ) .

      vbeln_convert = |{ vbeln alpha = in }|.

      select vbeln, posnr, pargb
        into table @data(tab)
        from vbap
       where vbeln eq @vbeln_convert
         and abgru eq @abgru .

      if ( sy-subrc eq 0 ) .

        delete tab where pargb is initial .

        if ( lines( tab ) gt 0 ) .

          pargb = tab[ 1 ]-pargb .

        endif .

        free:
          tab .

      endif .

    endif .

  endmethod.


  method read.

    if ( container is not initial ) .

      call method cl_abap_container_utilities=>read_container_c
        exporting
          im_container           = container
        importing
          ex_value               = value
        exceptions
          illegal_parameter_type = 1
          others                 = 2.

      if ( sy-subrc eq 0 ) .
      else .
        clear value .
      endif .

    endif .

  endmethod.


  method read_vbap.

    zcl_sd_extensionin=>read(
      exporting
        container = container
      importing
        value     =  value
      ) .

  endmethod.


  method read_vbapx.

    zcl_sd_extensionin=>read(
      exporting
        container = container
      importing
        value     =  value
      ) .

  endmethod.


endclass.
