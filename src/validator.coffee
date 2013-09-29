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
				showError(elem.name, k, opts)
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
	


# 验证方法
$.validateRules = 
	required: (value, elem, param) ->
		if elem.nodeName.toLowerCase() is 'select'
			val = $(elem).val()
			return val and val.length > 0

		if checkable(elem)
			return getLength(value, element) > 0
		return $.trim(value).length > 0
# 默认参数
defalutConfig = 
	identifie: '[required]'
	klass: 'error'
	form: 'form'
	isErrorOnParent: false
	event: 'blur'
	submit: true
	errElem: 'cite'


$.fn.simpleValidate = (opts) ->
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
			check $(@).attr('name'), v, opts
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
			checkAll.call(this, opts)			
		)
	return


# 提交验证
$('.btn_recharge').simpleValidate(
	identifie: 
		login_passwd:
			required: true
		pay_passwd: 
			required: true
		re_pay_passwd: 
			required: true
			equalTo: '#pay_passwd'
		question:
			required: true
		answer:
			required: true
	message: 
		login_passwd:
			required: '登陆密码不能为空'
		pay_passwd: 
			required: '支付密码不能为空'
		re_pay_passwd: 
			required: '支付密码不能为空'
			equalTo: '2次输入的密码不一致'
		answer:
			required: '答案不能为空'

	klass: 'inp_error'
	form: '.form_mc'
	submit: false
)
	
