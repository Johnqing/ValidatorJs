前端验证框架
===========

## 前提

依赖于 `jquery`

## 用法

```
// 第一个参数为提交按钮，如：'.submit' | '#submit' | '[data-type=submit]' 等
// 第二个参数为配置项
validator.Form.init('', {});
```

### 配置项

```
{
    // 该项为规则项。对象中的key为规则名，value为返回值需要对比的内容
    rules: {
        required: true
    },
    // 剔除一些不需要 验证的内容
    dataIg: 'data-ig',
    // 错误class
    klass: 'error',
    // 聚焦class
    fKlass: null,
    // 成功class
    sucKlass: 'success',
    // ajax时，可以不需要form元素
    form: '[data-type="form"]',
    // 触发事件
    event: 'blur',
    //提交方式，默认同步提交，直接提交form，如果设为true，则异步提交
    isAsync: false,
    // 错误信息包裹元素
    errElem: 'cite',
    // debug调试时使用
    debug: false,
    // 成功后的回调
    success:function(data){     },
    // 报错时的回调
    error:function(){    }
}
```

## 新的验证规则添加

```
validator.Form.rules['规则名'] = function(value, elem, param){
    //规则函数返回3个参数, value: 值，elem：当前元素，param：配置项中 rules对象中的 value
    //规则内容
}
```

## 当前支持规则

+ 空 required
+ 手机号 isMobile
+ 身份证号 certificate



