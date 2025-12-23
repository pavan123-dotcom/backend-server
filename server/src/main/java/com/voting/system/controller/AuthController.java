package com.voting.system.controller;

import com.voting.system.model.ActiveToken;
import com.voting.system.model.Voter;
import com.voting.system.repository.ActiveTokenRepository;
import com.voting.system.repository.VoterRepository;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final VoterRepository voterRepository;
    private final ActiveTokenRepository activeTokenRepository;

    public AuthController(VoterRepository voterRepository, ActiveTokenRepository activeTokenRepository) {
        this.voterRepository = voterRepository;
        this.activeTokenRepository = activeTokenRepository;
    }

    @PostMapping("/verify")
    @Transactional
    public ResponseEntity<TokenResponse> verify(@RequestBody AuthRequest request) {
        // 1. Verify Voter Exists
        Voter voter = voterRepository.findById(request.getVoterId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid Voter ID"));

        // 2. Mock Face Match (In real world, verify request.faceHash matches voter.faceHash)
        // Ignoring actual hash check for prototype logic flow

        // 3. Status Check
        if (voter.isHasVoted()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "User has already voted.");
        }

        // 4. Update Status (Mark as Voted)
        voter.setHasVoted(true);
        voterRepository.save(voter);

        // 5. Generate One-Time Token
        String tokenUuid = UUID.randomUUID().toString();
        ActiveToken token = new ActiveToken(tokenUuid, LocalDateTime.now().plusMinutes(15));
        activeTokenRepository.save(token);

        // 6. Return Token (NO User ID)
        return ResponseEntity.ok(new TokenResponse(tokenUuid));
    }

    @Data
    static class AuthRequest {
        private String voterId;
        private String faceHash;
    }

    @Data
    static class TokenResponse {
        private String token;
        public TokenResponse(String token) { this.token = token; }
    }
}
