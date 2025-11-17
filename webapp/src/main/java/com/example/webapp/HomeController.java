package com.example.webapp;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.ui.Model;

import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Controller
public class HomeController {

    @GetMapping("/")
    public String index(HttpServletRequest request, Model model) {

        model.addAttribute("lenguaje", "Spring Boot");
        model.addAttribute("fechaHora", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        model.addAttribute("ip", request.getRemoteAddr());
        model.addAttribute("navegador", request.getHeader("User-Agent"));
        model.addAttribute("versionJava", System.getProperty("java.version"));

        return "index";
    }

    @GetMapping("/contacto")
    public String contacto() {
        return "contacto";
    }
}
