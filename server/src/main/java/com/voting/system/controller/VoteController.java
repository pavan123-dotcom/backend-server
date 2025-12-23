package com.voting.system.controller;

import com.voting.system.model.ActiveToken;
import com.voting.system.model.Vote;
import com.voting.system.repository.ActiveTokenRepository;
import com.voting.system.repository.VoteRepository;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.UUID;

@RestController
@RequestMapping("/api/vote")
public class VoteController {

    private final VoteRepository voteRepository;
    private final ActiveTokenRepository activeTokenRepository;

    public VoteController(VoteRepository voteRepository, ActiveTokenRepository activeTokenRepository) {
        this.voteRepository = voteRepository;
        this.activeTokenRepository = activeTokenRepository;
    }

    @PostMapping("/cast")
    @Transactional
    public ResponseEntity<String> castVote(@RequestBody VoteRequest request) {
        // 1. Validate Token
        ActiveToken token = activeTokenRepository.findById(request.getTokenUuid())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.FORBIDDEN, "Invalid or Expired Token"));

        // 2. Check Expiry
        if (token.getExpiryTime().isBefore(LocalDateTime.now())) {
            activeTokenRepository.delete(token); // Cleanup
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Token Expired");
        }

        // 3. Record Vote (Anonymous)
        Vote vote = new Vote();
        vote.setVoteId(UUID.randomUUID());
        vote.setCandidateId(request.getCandidateId());
        vote.setTimestamp(LocalDateTime.now());
        voteRepository.save(vote);

        // 4. Redeem Token (Delete immediately)
        activeTokenRepository.delete(token);

        return ResponseEntity.ok("Vote Cast Successfully");
    }

    @Data
    static class VoteRequest {
        private String tokenUuid;
        private String candidateId;
    }
}
