$ = jQuery

#默认配置项
defaultConfig = 

	# 需要选中的元素
	ident: '[require]'

	# 错误提示
	errorClass: 'error'

	# 是否把错误class写到父级元素上 
	isParent: false

	# 执行事件
	event: 'blur'

	# 设置submit按钮
	# {false | String}
	submitBtn: false

	# debug
	debug: false

	# 前回调
	beforeCallback: ->

	# 后回调
	afterCallback: ->


# 方法集合
rules = 
	email: 

# 点击按钮时的设置和验证
validateSubmit = (opts) ->
	self = @

	if opts.submitBtn
		self.delegate(opts.submitBtn, 'click', (evt) ->			
			self.trigger('submit')
		)	

		self.submit( (evt) ->

			# debug模式下 不提交
			if opts.debug
				evt.preventDefault()
				return false;

			if !checkForm.call(self, opts)
				return false
						
		)
		return	


# 检查当前拥有的表单项
checkForm = (opts) ->
	items = @find opts.ident
	field = []
	items.each( ->
		(field = validate.call(@, opts.errorClass, opts.isParent)) && field.push(@)
		return
	)
	return !field.length

# 验证公共函数
validate = (errCls, isParent) ->



$.fn.validate = (opts) ->
	opts = $.extend {}, defaultConfig, opts
	return @each( ->
		self = $(@)
		ident = opts.ident

		# add novalidate
		# 去除默认样式
		self.attr("novalidate", "novalidate")

		# submit
		
		validateSubmit.call(@, opts)

		# 当用户聚焦到某个表单时去除错误提示
		self.on('focusein', ident, ->

		)		

		return
	)
