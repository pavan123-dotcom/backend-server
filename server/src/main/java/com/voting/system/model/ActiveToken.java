package com.voting.system.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "active_tokens")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActiveToken {
    @Id
    private String tokenUuid;
    
    private LocalDateTime expiryTime;
}
