$ = jQuery

# checkable
checkable = (element) ->
	return (/radio|checkbox/i).test(element.type)
# findName
findByName = (name) ->
	return $('.form_mc').find("[name='" + name + "']")
# 
getLength = (value, element) ->
	switch element.nodeName.toLowerCase()
		when "select" then return $("option:selected", element).length
		when "input"
			if this.checkable(element)
				return findByName(element.name).filter(":checked").length
	return value.length;

# 获取所有需要验证的项
getValidItem = (names, form, callback) ->
	for k, v of names
		item = $('[name='+k+']', form)
		if item.length
			callback and callback item, k, v
	return
			
# checkAll
checkAll = (opts) ->
	names = opts.identifie
	form = opts.form

	arr = []

	getValidItem(names, form, (item, k, v) ->
		if not check(item, v, opts)
			arr.push(v)
		return
	)

	return arr.length is 0
	
# 验证单独一项
check = (elem, valid, opts) ->
	elem = elem[0]
	for k, v of valid
		method = $.validateRules[k]
		if method
			res = method(elem.value, elem, v)
			if not res
				showError elem.name, k, opts
				return res
			else
				removeError elem.name, k, opts
	return res
		
# 显示错误信息	
showError = (name, k, opts) ->
	item = $ `'[name='+ name +']', opts.form`
	errWrap = $('[data-errwrap='+name+']')
	item.addClass(opts.klass)
	if errWrap.length		
		errWrap.addClass(opts.klass)
		return
	errWrap = $(`'<'+ opts.errElem +' data-errwrap='+name+' class="'+opts.klass+'">'+ opts.message[name][k] +'</'+ opts.errElem +'>'`)

	item.parents('li').append(errWrap)
	return
# 删除成功项
removeError = (name, k, opts) ->
	item = $ `'[name='+ name +']', opts.form`
	errWrap = $('[data-errwrap='+name+']')
	item.removeClass opts.klass
	if not errWrap.length
		return
	errWrap.text('').removeClass opts.klass
	return
	


# 验证方法
$.validateRules = 
	required: (value, elem, param) ->
		if elem.nodeName.toLowerCase() is 'select'
			return elem.selectedIndex != 0;

		if checkable(elem)
			return getLength(value, element) > 0
		return $.trim(value).length > 0
	equalTo: (value, elem, param) ->
		param = param.replace '#',''
		pv = $(`'[name='+param+']'`).val()
		return $.trim(pv) is $.trim(value)
	setPwd: (value, elem, param) ->
		reg = /^[x00-x7f]+$/

		if not reg.test value
			return false
		if value.length < 6 or value.length > 18
			return false

		return true

# 默认参数
defalutConfig = 
	identifie: '[required]'
	klass: 'error'
	form: 'form'
	isErrorOnParent: false
	event: 'blur'
	submit: true
	isAjaxSubmit: false
	errElem: 'cite'


$.fn.simpleValidate = (opts, callback) ->
	opts = $.extend {}, defalutConfig, opts

	form = opts.form
	identifie = opts.identifie
	method = opts.method
	klass = opts.klass
	isErrorOnParent = opts.isErrorOnParent

	getValidItem(identifie, form, (item, k, v) ->
		if checkable(item) || item[0].nodeName.toLowerCase() is 'select'
			opts.event = 'change blur'
		item.on(opts.event, ->
			check $(@), v, opts
			return
		)
		return
	)
	

	if opts.submit
		$(@).on('click',->
			$(form).trigger('submit')
			return
		)
		$(form).submit((event) ->
			if opts.debug
				event.preventDefault()
				return false
			checkAll.call(this, opts)			
		)
	else
		$(@).on('click', (event) ->
			if opts.debug
				event.preventDefault()
				return false
			checkStata = checkAll.call(this, opts)
			if  checkStata and opts.isAjaxSubmit
				callback and callback()
				
				return checkStata
			return	
		)
	return