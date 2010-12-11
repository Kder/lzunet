--[[ Copyright (c) 2010 god6or@gmail.com under MIT license.

    Unicode string class.

    Examples:
        - create new string from UTF-8 (default) encoded string: s = string.Str:new('qwertyйцукен')
        - create new string from Base-64 and UTF-8 encoded string: s = string.Str:new('cXdlcnR50LnRhtGD0LrQtdC9AA==', {'b64','utf8'})
        - encode to CP1251: s:enc('cp1251')
        - encode to UTF8, then URL-escape: s:enc({'utf8','url'})
        - encode to UTF16-escape, then Base64: s:enc({'esc','b64'})
        - get length (number of code units): s:len(), s:__len()
        - get number of code points: s:ncp()
        - extract substring (first char has index 1): s:sub(3,6), s:sub(1,-3)
        - repeat 3 times: s:rep(3) or s*3
        - concatenate 2 strings: s:add('abcd') or s1 + s2
        - find first/last substring: s:find('rty'), s:find('rty', true)
        - check if s starts/ends with substring: s:starts('abc'), s:ends('abc')
        - compare 2 strings: print(s == s2, s3 <= s2)
        - convert to lower/upper case: s:lower(), s:upper()
        - adjust string to the left/right/center: s:ljust(5,'0')/rjust/center
        - strip substrings from the left/right/center: s:lstrip('0',5)/rstrip/strip
        - mirror string: s:mirror()
        
        - search Regexp: for match in s:gmatch(regexp, flags, start_index) do...
          - regexp - Regex string or Str object
          - flags - string containing Regex flags:
              'I' - ignore case,
              'S' - DOTALL (dot matches \r\n),
              'M' - multiline,
              'U' - unicode word letters.
          - start_index - starting search index (default is 1)
        
        -   match - object with attributes:
            - ng - number of match groups,
            - group(n) - returns substring with nth match group (0 - whole regexp),
            - gs(n), ge(n) - returns nth group start/end indices.
        
        -   s = Str:new('2004.10.11 2005.11.01')
            for match in s:gmatch('([0-9]{4}).([0-9]{1,2}).([0-9]{1,2})') do
              print('Groups: ',match.ng)
              for gc=0,match.ng do
                print(gc, match:group(gc))
              end
            end

        
    Gettext functions (module gettext):
        -   read translation catalog from './locale' folder, 'coreutils' domain:
              gettext.cat=gettext.parseCat('./locale','coreutils','MESSAGES',true,true)
        -   set current translation language:
              gettext.lang = 'de'
        -   translate string:
              local _ = gettext.tr
              print(_('hello'))
        -   translate string to plural form:
              print(_('hello',2))

        
    Locale functions (module locale):
        -   normalize locale name:
              print(locale.norm('en_gb'))
        -   extract language code:
              print(locale.lang('en_gb'))
        -   extract 3-letter language code:
              print(locale.lang3('en_gb'))
        -   get display language translated to french:
              print(locale.dlang('en_gb','fr'))
        -   extract country code:
              print(locale.country('en_gb'))
        -   extract 3-letter country code:
              print(locale.country3('en_gb'))
        -   get display country translated to german:
              print(locale.dcountry('en_us','de'))
        -   get locale display name translated to japanese:
              print(locale.dname('en_us','ja'))
]]

require'_ul_str'

-- Unicode string class
string.Str = {

    encFrom = 'utf8', -- default input encoding
    encTo   = 'utf8', -- default output encoding
    s       = '',     -- UTF16-encoded string

    -- create new string.
    --   str - input string,
    --   enc - input string encoding (default is self.encFrom),
    --   encFrom, encTo - default from- and to-encodings,
    --   initS - initial UTF16-encoded string.
    new = function(self, str, enc, encFrom, encTo, initS)
        str = tostring(str)
        if encFrom then self.encFrom = encFrom end
        if encTo then self.encTo = encTo end
        if not enc then enc = self.encFrom end
        
        local s = {}
        setmetatable(s, self)
        self.__index = self
        if initS then s.s = initS
        else s.s = self:dec(str, enc) end
        return s
    end,

    -- decode str from encoding enc (self.encFrom is default)
    dec = function(self, str, enc)
        if not str then str = '' end
        if not enc then enc = self.encFrom end
        if type(enc) == 'string' then enc = {enc} end

        if (type(enc) == 'table') then -- and (#str > 0) then
            for i=1,table.maxn(enc) do
                local e = enc[i]:lower()
                if e == 'escape' or e == 'esc' then str = _ul_str.unescape(str) -- Unicode escape
                elseif e == 'hex' then str = self.decHex(str) -- HEX bytes
                elseif e == 'hesc' or e == 'hexesc' then str = self.decHexEsc(str) -- HEX escape
                elseif e == 'base64' or e == 'b64' then str = self.decB64(str) -- Base64
                elseif e == 'url' then str = self.decURL(str) -- URL escape
                else str = _ul_str.dec(str, e) end -- any other encoding
            end
        end
        return str
    end,
    -- encode str to encoding enc (self.encTo is default)
    enc = function(self, enc, str)
        if not str then str = self.s end
        if not enc then enc = self.encTo end
        if type(enc) == 'string' then enc = {enc} end
        
        if (type(enc) == 'table') then --and (#str > 0) then
            for i=1,table.maxn(enc) do
                local e = enc[i]:lower()
                if e == 'esc' or e == 'escape'  then str = self.encEsc(str)
                elseif e == 'hex' then str = self.encHex(str)
                elseif e == 'hexesc' then str = self.encHexEsc(str)
                elseif e == 'b64' or e == 'base64' then str = self.encB64(str)
                elseif e == 'url' then str = self.encURL(str)
                else str = _ul_str.enc(str, e) end
            end
        end
        return str
    end,

    -- Unicode-escape UTF-16 string
    encEsc = function(str)
        return str:gsub('(..)', function(c) return string.format('\\u%04X',c:byte()+c:byte(2)*256) end)
    end,
    
    -- HEX-encode string
    encHex = function(str)
        return str:gsub('(.)', function(c) return string.format('%02X',c:byte()) end)
    end,
    -- HEX-decode string
    decHex = function(str)
        return str:gsub('(%x%x)', function(h) return string.char(tonumber(h,16)) end)
    end,
    
    -- HEX-escape string
    encHexEsc = function(str)
        return str:gsub('(.)', function(c) return string.format('\\x%02X',c:byte()) end)
    end,
    -- HEX-unescape string
    decHexEsc = function(str)
        return str:gsub('\\x(%x%x)', function(h) return string.char(tonumber(h,16)) end)
    end,

    -- URL-encode/decode string. Code from http://lua-users.org/wiki/StringRecipes
    encURL = function(str)
        str = str:gsub("\n", "\r\n")
        str = str:gsub("([^%w ])", function (c) return string.format("%%%02X", c:byte()) end)
        str = str:gsub(" ", "+")
        return str
    end,
    decURL = function(str)
        str = str:gsub("+", " ")
        str = str:gsub("%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
        str = str:gsub(str, "\r\n", "\n")
        return str
    end,
    
    -- Base64-encode/decode. Code from http://lua-users.org/wiki/BaseSixtyFour
    encB64 = function(data)
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        return ((data:gsub('.', function(x) 
            local r,b='',x:byte()
            for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
            return r;
        end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if (#x < 6) then return '' end
            local c=0
            for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
            return b:sub(c+1,c+1)
        end)..({ '', '==', '=' })[#data%3+1])
    end,
    decB64 = function(data)
        local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        data = data:gsub('[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if (x == '=') then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if (#x ~= 8) then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end,

    -- get string length (number of code units)
    __len = function(self)
        return _ul_str.len(self.s)
    end,
    len = function(self)
        return self:__len()
    end,
    -- get number of code points
    ncp = function(self)
        return _ul_str.ncp(self.s)
    end,

    upper = function(self)
        return string.Str:new('','ascii',self.encFrom,self.encTo,_ul_str.upper(self.s))
    end,
    lower = function(self)
        return string.Str:new('','ascii',self.encFrom,self.encTo,_ul_str.lower(self.s))
    end,

    -- returns position of first/last occurence of substring
    find = function(self, sub, back)
        if type(sub) ~= 'table' then sub = self:dec(tostring(sub))
        else sub = sub.s end
        return _ul_str.find(self.s, sub, back == true)
    end,
    -- returns true if string starts with sub
    starts = function(self, sub)
        return self:find(sub) == 1
    end,
    -- returns true if string starts with sub
    ends = function(self, sub)
        if type(sub) ~= 'table' then sub = self:dec(tostring(sub))
        else sub = sub.s end
        return self:find(sub, true) == (self:len() - _ul_str.len(sub) + 1)
    end,

    -- justify string to the right. l - result length, c - padding string (default is ' ')
    rjust = function(self, l, c)
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local s = string.Str:new('','ascii',self.encFrom,self.encTo, _ul_str.add(_ul_str.mul(c, math.floor((l-self:len())/_ul_str.len(c) + 0.5)), self.s))
        if s:len() > l then s = s:sub(s:len() - l + 1) end
        return s
    end,
    -- justify string to the left. l - result length, c - padding string (default is ' ')
    ljust = function(self, l, c)
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local s = string.Str:new('','ascii',self.encFrom,self.encTo, _ul_str.add(self.s, _ul_str.mul(c, math.floor((l-self:len())/_ul_str.len(c) + 0.5))))
        if s:len() > l then s = s:sub(1, l) end
        return s
    end,
    -- center string. l - result length, c - padding string (default is ' ')
    center = function(self, l, c)
        local s = self.s
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local len = self:len()
        local cl = _ul_str.len(c)
        if l > len then
            local al = math.floor((l - len)/2 + 0.5)
            s = _ul_str.add( _ul_str.add( _ul_str.mul(c, al), s), _ul_str.mul(c, l - len - al))
            len = _ul_str.len(s)
        end
        --[[if len > l then
            local al = math.floor((len - l)/2 + 0.5)
            print(len,l,al,al*2 + 1, al*2 + 2 + l*2)
            s = s:sub( al*2 + 1, al*2 + 2 + l*2 )
        end]]
        return string.Str:new('','ascii',self.encFrom,self.encTo, s)
    end,

    -- strip substrings c from right. c - stripped substring (default is ' '), l - minimal length
    rstrip = function(self, c, l)
        local s = '' .. self.s
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local cl = _ul_str.len(c)
        if not l then l = 0 end
        local sl,found = _ul_str.len(s),true
        while (sl > l) and found do
            local pos = _ul_str.find(s, c, true)
            found = pos == (sl - cl + 1)
            if found then
                s = self:sub(1, sl - cl, true, s)
                sl = _ul_str.len(s)
            end
        end
        return string.Str:new('','ascii',self.encFrom,self.encTo, s)
    end,
    -- strip substrings c from left. c - stripped substring (default is ' '), l - minimal length
    lstrip = function(self, c, l)
        local s = '' .. self.s
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local cl = _ul_str.len(c)
        if not l then l = 0 end
        local sl,found = _ul_str.len(s),true
        while (sl > l) and found do
            local pos = _ul_str.find(s, c, false)
            found = pos == 1
            if found then
                s = self:sub(cl+1, -1, true, s)
                sl = _ul_str.len(s)
            end
        end
        return string.Str:new('','ascii',self.encFrom,self.encTo, s)
    end,
    -- strip substrings c. c - stripped substring (default is ' '), l - minimal length
    strip = function(self, c, l)
        local s = '' .. self.s
        if not c then c = ' ' end
        if type(c) ~= 'table' then c = self:dec(tostring(c))
        else c = c.s end
        local cl = _ul_str.len(c)
        if not l then l = 0 end
        local sl,found = _ul_str.len(s),true
        while (sl > l) and found do
            local pos = _ul_str.find(s, c, false)
            local lfound,rfound = pos == 1, false
            if lfound then
                s = self:sub(cl+1, -1, true, s)
                sl = _ul_str.len(s)
            end
            if sl > l then
                pos = _ul_str.find(s, c, true)
                rfound = pos == (sl - cl + 1)
                if rfound then
                    s = self:sub(1, sl - cl, true, s)
                    sl = _ul_str.len(s)
                end
            end
            found = lfound or rfound
        end
        return string.Str:new('','ascii',self.encFrom,self.encTo, s)
    end,

    -- return mirrored string
    mirror = function(self)
        local s = {}
        for c=self:len()*2-1,1,-2 do table.insert(s, self.s:sub(c, c+1)) end
        table.insert(s, '\00\00')
        s = table.concat(s, '')
        return string.Str:new('','ascii',self.encFrom,self.encTo, s)
    end,
    
    -- get substring from i to j. If raw==true, returns internal representation of substring
    sub = function(self, i, j, raw, s)
        if not s then s = self.s end
        local l = _ul_str.len(s)
        if not i then i = 1 end
        if not j then j = -1 end
        if i < 0 then i = l + i + 1 end
        if j < 0 then j = l + j + 1 end
        if j > l then j = l end
        if (i >= 1) and (i <= l) and (j >= 1) and (j <= l) and (j >= i) then
            s = s:sub(i*2 - 1, j*2) .. '\00\00'
        else s = '\00\00'
        end
        -- create new string
        if raw then return s
        else return string.Str:new('','ascii',self.encFrom,self.encTo,s)
        end
    end,

    -- split to substrings
    --   sep - separator Regex
    --   flags - separator Regex flags (I,S,M,U)
    split = function(self, sep, flags)
        local result = {}
        local pi = 1 -- index after previous match
        for m in self:gmatch(sep, flags) do
            table.insert(result, self:sub(pi, m:gs(0) - 1))
            pi = m:ge(0) + 1
        end
        if next(result) then table.insert(result, self:sub(pi, -1)) end
        return result
    end,

    -- Match Regex. Returns iterator with search result.
    --   re - Regex (string or Str)
    --   flags - string with chars I,S,M,U representing flags CASE_INSENSITIVE,DOTALL,MULTILINE,UWORD
    --   start - starting search index (default is 1)
    -- Result is an object with keys:
    --   ng        - number of capture groups,
    --   gs(n) - returns match starting index,
    --   ge(n)   - returns match ending index,
    --   group(n)  - returns nth capture group (n=0 returns whole match),
    --   groups()  - returns array of all capture groups.
    gmatch = function(self, re, flags, start)
        if type(re) ~= 'table' then re = self:dec(tostring(re))
        else re = re.s end
        local f = 0
        if flags then
            flags = flags:upper()
            for i=1,#flags do
                if _ul_str['re'..flags:sub(i,i)] then
                    f = f + _ul_str['re'..flags:sub(i,i)]
                end
            end
        end
        if not start then start = 1 end
        
        local match = 0
        return function()
            local found = false
            if match == 0 then -- create new match
                match = _ul_str.reNew(re, f)
                if match then found = _ul_str.reFind(match, self.s, start) end
            else found = _ul_str.reFindNext(match) end
            if found then -- match found - return result object
                local mObj = {
                    m = match,
                    ng = _ul_str.reNGroups(match),
                    group = function(self, n)
                        if not n then n = 0 end
                        return string.Str:new('','ascii',self.encFrom,self.encTo,_ul_str.reGroup(self.m, n))
                    end,
                    gs = function(self, n)
                        if not n then n = 0 end
                        return _ul_str.reStart(self.m, n)
                    end,
                    ge = function(self, n)
                        if not n then n = 0 end
                        return _ul_str.reEnd(self.m, n)
                    end,
                }
                return mObj
            end
        end
    end,

    -- Conversion to string (using self.encTo encoding)
    __tostring = function(self)
        return self:enc()
    end,

    -- comparison metamethods
    cmp = function(a, b) -- returns < 0 >
        if type(b) ~= 'table' then b = a:dec(tostring(b))
        else b = b.s end
        return _ul_str.cmp(a.s, b)
    end,
    __eq = function(a, b) -- a == b
        if type(b) ~= 'table' then b = a:dec(tostring(b))
        else b = b.s end
        return _ul_str.cmp(a.s, b) == 0
    end,
    __lt = function(a, b) -- a < b
        if type(b) ~= 'table' then b = a:dec(tostring(b))
        else b = b.s end
        return _ul_str.cmp(a.s, b) < 0
    end,
    lt = function(a,b) return a:__lt(b) end,
    __le = function(a, b) -- a <= b
        if type(b) ~= 'table' then b = a:dec(tostring(b))
        else b = b.s end
        return _ul_str.cmp(a.s, b) <= 0
    end,
    eq = function(a,b) return a:__eq(b) end,
    le = function(a,b) return a:__le(b) end,
    gt = function(a,b) return not a:__le(b) end,
    ge = function(a,b) return not a:__lt(b) end,

    -- add metamethod - concatenate 2 strings
    __add = function(self, b)
        if type(b) ~= 'table' then b = self:dec(tostring(b))
        else b = b.s end
        return string.Str:new('','ascii',self.encFrom,self.encTo,_ul_str.add(self.s,b))
    end,
    __concat = function(self,b)
        return self:__add(b)
    end,
    add = function(self,b)
        return self:__add(b)
    end,

    -- mul metamethod - repeat string n times
    __mul = function(self, n)
        return string.Str:new('','ascii',self.encFrom,self.encTo,_ul_str.mul(self.s, n))
    end,
    mul = function(self, n)
        return self:__mul(n)
    end,
    rep = function(self, n)
        return self:__mul(n)
    end,
}



-- gettext functions
gettext = {
    langDef = 'en', -- default language (original language, not present in catalog)
    lang = 'en',    -- current language
    cat = {},       -- parsed catalog dictionary (in format { lang1={ mes1={{singgular1,plural1,...},{orig1,orig2}}, mes2=...}, lang2={...}, }
    
    -- translation function
    --   s - original string
    --   pl - plural form (default is 1)
    --   lang - translation language (default is gettext.lang)
    --   cat - translation catalog (output of parseCat function - default if gettext.cat)
    tr = function(s, pl, lang, cat)
        if not pl then pl = 1 end
        if not lang then lang = gettext.lang end -- use current language if not given
        if not cat then cat = gettext.cat end -- use current catalog dictionary if not given
        if cat[lang] and cat[lang][s] then
            if pl <= table.maxn(cat[lang][s][1]) then return cat[lang][s][1][pl] -- return translation if found
            elseif pl > 1 and cat[lang][s][2] and cat[lang][s][2][2] then return cat[lang][s][1][pl]
            else return s
            end
        else return s end
    end,

    -- returns array of languages present in catalog
    --   cat - table of parsed translations catalog (default is gettext.cat)
    --   sort==true to sort languages in ascending order, false - in descending
    langs = function(cat, sort)
        if not cat then cat = gettext.cat end -- use default catalog if not given
        local ld = {gettext.langDef} -- include default language first
        for lang,_ in pairs(cat) do table.insert(ld, lang) end
        if sort == true then table.sort(ld) end
        if sort == false then table.sort(ld, function(a,b) return a>b end) end
        return ld
    end,
    
    -- loads and parses .mo file into table where keys are original strings, values are arrays with translated strings/Str objects.
    -- (based on code from http://lua-list.2524044.n2.nabble.com/State-of-Lua-and-GNU-gettext-td4797364.html )
    --   mo - string containing .mo file
    --   tnulls==true to include terminating nulls in original/translation strings
    --   unistr==true to create Unicode strings instead of Lua strings
    parseMO = function(mo, tnulls, unistr)
        local tn = 0
        if tnulls then tn = 1 end
        local dict = {} -- parsed dictionary. Keys - original strings, values - array where 1st item is singular form, 2nd-plural
        local magick = mo:sub(1,4) -- magick number
        
        local s2l
        if magick == '\149\04\18\222' then
            s2l = function(s,a)
                 local a,b,c,d = s:byte(a+1, a+4)
                 return ((a * 256 + b) * 256 + c) * 256 + d
            end
        elseif magick == '\222\18\04\149' then
            s2l = function(s,a)
                 local a,b,c,d = s:byte(a+1, a+4)
                 return ((d * 256 + c) * 256 + b) * 256 + a
            end
        end

        if s2l then
            local rev = s2l(mo,4) -- revision number
            local revMaj = math.floor(rev / 65536)
            local revMin = rev % 65536
            local ns = s2l(mo,8) -- number of strings
            local oto = s2l(mo,12) -- offset of table with original strings
            local ott = s2l(mo,16) -- offset of table with translation strings
            
            if revMaj <= 1 and revMin <= 1 then -- exit if wrong format revision
            
                -- load original and translation strings
                for nsc=1,ns do
                    local osl,oso,tsl,tso = s2l(mo,oto),s2l(mo,oto+4), s2l(mo,ott),s2l(mo,ott+4)
                    local os,osp,ts,tss = mo:sub(oso+1,oso+osl),nil,mo:sub(tso+1,tso+tsl+1),{{}} -- original,translation string,plural forms table
                    local oszps,oszpe = os:find('\0',1,true) -- cut original plural
                    if oszps and oszps < #os then -- original plural form present - extract it
                        osp = os:sub(oszps+1, #os) -- original singular
                        os = os:sub(1, oszps-1) -- original plural
                        if unistr then osp = string.Str:new(osp,'utf8','utf8') end
                    end
                    if unistr then tss[2] = {string.Str:new(os,'utf8','utf8'), osp}
                    else tss[2] = {os, osp} end
                    
                    -- find all translation plural forms
                    local zpsp,zps,zpe=1,1,1
                    while zps <= #ts do
                        zps,zpe = ts:find('\0',zpsp,true) -- find next zero
                        if zps then
                            -- add next plural form
                            if not unistr then table.insert(tss[1], ts:sub(zpsp,zps+tn-1))
                            else table.insert(tss[1], string.Str:new(ts:sub(zpsp,zps+tn-1),'utf8','utf8')) end
                            zpsp = zps + 1
                        else break end
                    end
                    dict[os] = tss -- store singular and plural form to result dictionary
                    oto,ott = oto+8,ott+8
                end
            end
        end
        return dict
    end,

    -- read localization catalog
    --   root - root path to catalog
    --   domain - translation domain (default is 'messages')
    --   category - translation category (default is 'MESSAGES')
    --   tnulls==true to leave terminating zeroes in strings
    --   unistr==true to convert translation strings to Str objects, else leaves strings as UTF-8 lua-strings
    parseCat = function(root, domain, category, tnulls, unistr)
        if not root then root = './locale' end
        if not category then category = 'LC_MESSAGES' else category = 'LC_'..category end
        if not domain then domain = 'messages' end
        
        local dict = {}
        if lfs.attributes(root) and lfs.attributes(root).mode == 'directory' then
            for dir in lfs.dir(root) do
                if dir ~= '.' and dir ~= '..' then
                    local mof = io.open(root..'/'..dir..'/'..category..'/'..domain..'.mo', 'rb')
                    if mof then
                        local mod = gettext.parseMO(mof:read('*a'), tnulls, unistr)
                        if next(mod) then dict[dir] = mod end
                        mof:close()
                    end
                end
            end
        end
        return dict
    end,
}


-- Locale functions
locale = {
	
	current = 'en', -- current locale
    
    -- normalize locale name
    norm = function(loc)
    	if not loc then loc = locale.current end
        if type(loc) == 'table' then return string.Str:new(_ul_str.locNorm(loc:enc('ascii')), 'ascii')
        else return _ul_str.locNorm(loc) end
    end,

    -- get language code for locale loc
    lang = function(loc)
    	if not loc then loc = locale.current end
        if type(loc) == 'table' then return string.Str:new(_ul_str.locLang(loc:enc('ascii')), 'ascii')
        else return _ul_str.locLang(loc) end
    end,
    -- get ISO3 language code for locale
    lang3 = function(loc)
    	if not loc then loc = locale.current end
        if type(loc) == 'table' then return string.Str:new(_ul_str.locLang3(loc:enc('ascii')), 'ascii')
        else return _ul_str.locLang3(loc) end
    end,
    -- get display language for locale loc, dloc is translation language (default is 'en_US')
    -- result is instance of string.Str
    dlang = function(loc, dloc)
    	if not loc then loc = locale.current end
        if not dloc then dloc = 'en_US' end
        if type(loc) == 'table' then loc = loc:enc('ascii') end
        return string.Str:new('','ascii',nil,nil,_ul_str.locDLang(loc, dloc))
    end,

    -- get country code for locale
    country = function(loc)
    	if not loc then loc = locale.current end
        if type(loc) == 'table' then return string.Str:new(_ul_str.locCountry(loc:enc('ascii')), 'ascii')
        else return _ul_str.locCountry(loc) end
    end,
    -- get ISO3 language code for locale
    country3 = function(loc)
    	if not loc then loc = locale.current end
        if type(loc) == 'table' then return string.Str:new(_ul_str.locCountry3(loc:enc('ascii')), 'ascii')
        else return _ul_str.locCountry3(loc) end
    end,
    -- get display country for locale loc, dloc is translation language (default is 'en_US')
    -- result is instance of string.Str
    dcountry = function(loc, dloc)
    	if not loc then loc = locale.current end
        if not dloc then dloc = 'en_US' end
        if type(loc) == 'table' then loc = loc:enc('ascii') end
        return string.Str:new('','ascii',nil,nil,_ul_str.locDCountry(loc, dloc))
    end,

    -- get display name for locale loc, dloc is translation language (default is 'en_US')
    -- result is instance of string.Str
    dname = function(loc, dloc)
    	if not loc then loc = locale.current end
        if not dloc then dloc = 'en_US' end
        if type(loc) == 'table' then loc = loc:enc('ascii') end
        return string.Str:new('','ascii',nil,nil,_ul_str.locDName(loc, dloc))
    end,
}

