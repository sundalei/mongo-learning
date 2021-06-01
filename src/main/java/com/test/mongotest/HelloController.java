package com.test.mongotest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller
@RequestMapping("/page")
public class HelloController {

    @RequestMapping(value = "/new", method = RequestMethod.GET)
    public String create() {
        return "new";
    }
}
