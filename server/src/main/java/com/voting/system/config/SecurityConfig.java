package com.voting.system.config;

import com.voting.system.security.HmacFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final HmacFilter hmacFilter;

    public SecurityConfig(HmacFilter hmacFilter) {
        this.hmacFilter = hmacFilter;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Stateless API
            .headers(headers -> headers.frameOptions(f -> f.disable())) // For H2/Debug
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/**").permitAll() // We handle security via HMAC Filter manually
                .anyRequest().permitAll()
            )
            .addFilterBefore(hmacFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
