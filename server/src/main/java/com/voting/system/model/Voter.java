package com.voting.system.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "voters")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Voter {
    @Id
    private String voterId; // Aadhaar Hash
    
    private String name;
    
    private String faceHash;
    
    private boolean hasVoted;
}
