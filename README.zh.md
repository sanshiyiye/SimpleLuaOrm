# SimpleLuaOrm 10分钟教程

**翻译**: [English](README.md) | [中文](README.zh.md)

## 数据库配置

在开始之前，请先添加以下简单的数据库配置设置。创建一个全局变量 `DB`：

```lua
DB = {}
```

**开发配置：**

1. `new` - 如果为 `true`，则删除之前的数据库并创建新数据库（*默认：`true`*）
2. `backtrace` - 如果为 `true`，则在控制台显示警告、错误和信息消息（*默认：`true`*）
3. `DEBUG` - 如果为 `true`，则在控制台显示所有SQL查询（*默认：`true`*）

**数据库配置：**

1. `type` - 数据库类型（*默认：`"sqlite3"`*）：
    - `"mysql"` - MySQL数据库
    - `"postgres"` - PostgreSQL（*即将支持*）
2. `name` - SQLite的数据库文件路径；其他数据库的数据库名称（*默认：`"database.db"`*）
3. `username` - 数据库用户名（*默认：`nil`*）
4. `password` - 数据库密码（*默认：`nil`*）
5. `host` - 数据库主机（*默认：`nil`*）
6. `port` - 数据库端口（*默认：`nil`*）

配置完成后，添加以下模块导入：
```lua
local Table = require("orm.model")
local fields = require("orm.tools.fields")
```

## 创建表
```lua
local User = Table({
    __tablename__ = "user",
    username = fields.CharField({max_length = 100, unique = true}),
    password = fields.CharField({max_length = 50, unique = true}),
    age = fields.IntegerField({max_length = 2, null = true}),
    job = fields.CharField({max_length = 50, null = true}),
    time_create = fields.DateTimeField({null = true})
})
```
- 自动创建 `id` 主键列
- `__tablename__` 是必需的
- 字段选项：
  1. `max_length` - 字符串最大长度
  2. `unique` - 强制唯一值
  3. `null` - 允许NULL值
  4. `default` - 未提供值时的默认值
  5. `primary_key` - 设置为主键

## 表字段类型
1. `CharField` - VARCHAR类型
2. `IntegerField` - INTEGER类型
3. `TextField` - TEXT类型
4. `BooleanField` - BOOLEAN类型
5. `DateTimeField` - INTEGER类型（存储os.time()）
6. `PrimaryField` - 主键字段
7. `ForeignKey` - 表关系

## 创建数据
```lua
local user = User({
    username = "Bob Smith",
    password = "SuperSecretPassword",
    time_create = os.time()
})
user:save()  -- 保存到数据库
print("用户 " .. user.username .. " 的ID是 " .. user.id)
-- 用户 Bob Smith 的ID是 1
```

## 更新数据
```lua
user.username = "John Smith"
user:save()  -- 更新数据库
print("新用户名: " .. user.username) -- John Smith
```
或更新多条记录：
```lua
User.get:where({time_create__null = true})
        :update({time_create = os.time()})
```

## 删除数据
```lua
user:delete()  -- 删除单条记录
```
或删除多条记录：
```lua
User.get:where({username = "SomebodyNew"}):delete()
```

## 获取数据
创建测试数据：
```lua
users = {
    {username="First user", password="secret1", age=22},
    {username="Second user", password="secret_test", job="Lua developer"},
    {username="Another user", password="old_test", age=44},
    {username="New user", password="some_passwd", age=23, job="Manager"},
    {username="Old user", password="secret_passwd", age=44}
}
for _,u in ipairs(users) do User(u):save() end
```

获取记录：
```lua
local first_user = User.get:first()
print("第一个用户: " .. first_user.username) -- First user

local all_users = User.get:all()
print("总用户数: " .. all_users:count()) -- 5
```

### 限制和偏移
```lua
local users = User.get:limit(2):all()  -- 前2个用户
users = User.get:limit(2):offset(2):all()  -- 接下来2个用户
```

### 排序结果
```lua
users = User.get:order_by({desc('age'), asc('username')}):all()
```

### 分组结果
```lua
users = User.get:group_by({'age'}):all()
print('唯一年龄数: ' .. users:count()) -- 4
```

### Where和Having子句
```lua
user = User.get:where({username = "First user"}):first()
users = User.get:group_by({'id'}):having({age = 44}):all()
```

### 高级查询
```lua
users = User.get:where({age__lt=30, age__gt=10})
               :order_by({asc('id')})
               :group_by({'age','password'})
               :having({id__in={1,3,5}, username__null=false})
               :limit(2):offset(1):all()
```

### 表连接
创建关联表：
```lua
local News = Table({
    __tablename__ = "news",
    title = fields.CharField({max_length=100}),
    text = fields.TextField({null=true}),
    create_user_id = fields.ForeignKey({to=User})
})
```

使用连接查询：
```lua
local news = News.get:join(User):all()
print("第一条新闻作者: " .. news[1].user.username)

local user = User.get:join(News):first()
print("用户 "..user.id.." 有 "..user.news_all:count().." 条新闻")
for _,n in pairs(user.news_all) do print(n.title) end
```

## 自定义字段类型
创建邮箱字段：
```lua
fields.EmailField = fields:register({
    __type__ = "varchar",
    settings = {max_length=100},
    validator = function(value)
        return value:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")
    end
})
```

使用：
```lua
local UserEmails = Table({
    __tablename__ = "user_emails",
    email = fields.EmailField(),
    user_id = fields.ForeignKey()
})
```

## Corona SDK支持
即将推出...

## 结论
所有代码示例可在example.lua中找到。欢迎在项目中使用此ORM！祝您好运！