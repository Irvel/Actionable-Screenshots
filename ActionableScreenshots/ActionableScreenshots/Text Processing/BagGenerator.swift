//
//  BagGenerator.swift
//  ActionableScreenshots
//
//  Created by Irvel Nduva Matías Vega on 11/30/17.
//  Copyright © 2017 Jesus Galvan. All rights reserved.
//

import Foundation

let EN_STOP_WORDS: Set = ["they'd", "elsewhere", "almost", "than", "really", "can't", "j", "anywhere",
                         "insofar", "each", "tu", "merely", "onto", "becomes", "someone", "alone",
                         "it'll", "beyond", "okay", "with", "such", "relatively", "soon", "sent",
                         "specified", "whence", "novel", "using", "why", "allows", "they", "specify",
                         "where", "has", "was", "rd", "want", "there", "cant", "come",
                         "himself", "think", "example", "new", "thank", "despite", "q", "thereupon",
                         "too", "use", "course", "having", "all", "que", "gotten", "isn't",
                         "far", "maybe", "perhaps", "whom", "went", "upon", "asking", "contain",
                         "somewhat", "together", "my", "hither", "three", "them", "along", "name",
                         "only", "seriously", "took", "hereafter", "better", "didn't", "weren't", "uucp",
                         "any", "wherever", "always", "would", "look", "indeed", "further", "particularly",
                         "thru", "old", "c's", "next", "re", "help", "eg", "enough",
                         "others", "seen", "of", "we're", "whatever", "whither", "why's", "am",
                         "needs", "w", "both", "but", "own", "regards", "ok", "inc",
                         "able", "between", "et", "consequently", "less", "p", "placed", "si",
                         "likely", "five", "believe", "second", "known", "thoroughly", "thanx", "probably",
                         "right", "when's", "we'd", "now", "indicate", "selves", "provides", "downwards",
                         "s", "saying", "therein", "itself", "here's", "latter", "non", "wish",
                         "few", "anybody", "while", "since", "corresponding", "like", "concerning", "it'd",
                         "haven't", "mainly", "everywhere", "yo", "thence", "edu", "never", "becoming",
                         "yes", "welcome", "i", "up", "currently", "seemed", "when", "thus",
                         "hers", "none", "k", "normally", "plus", "let's", "hardly", "therefore",
                         "unto", "certainly", "she'd", "o", "immediate", "will", "take", "could",
                         "for", "our", "to", "four", "whereas", "getting", "thorough", "hello",
                         "r", "v", "white", "you'll", "herself", "during", "very", "into",
                         "most", "you've", "also", "came", "they've", "become", "little", "reasonably",
                         "us", "they'll", "regardless", "wants", "whereby", "being", "accordingly", "x",
                         "he'd", "hadn't", "he'll", "looking", "namely", "seven", "after", "doing",
                         "ours", "your", "its", "don't", "according", "i'd", "i'll", "we've", "they're",
                         "how's", "you'd", "the", "below", "did", "ie", "still", "formerly", "he's",
                         "try", "see", "following", "nine", "shall", "regarding", "near", "f", "he'll",
                         "hence", "usually", "saw", "moreover", "against", "twice", "anything", "via",
                         "moi", "unfortunately", "specifying", "him", "clearly", "done", "either", "quite",
                         "seem", "hereby", "me", "besides", "thereafter", "n", "herein", "nevertheless",
                         "anyway", "ones", "through", "nobody", "outside", "wherein", "vs", "various",
                         "as", "oh", "actually", "keep", "fifth", "anyways", "possible", "she'll",
                         "once", "awfully", "doesn't", "allow", "won't", "that's", "tell", "mostly",
                         "happens", "different", "ought", "shan't", "even", "somewhere", "do", "associated",
                         "comes", "must", "say", "every", "used", "go", "keeps", "kept", "she's",
                         "out", "going", "got", "who's", "towards", "over", "everything", "seems",
                         "secondly", "a's", "c", "whereafter", "inasmuch", "is", "though", "what",
                         "myself", "it's", "instead", "need", "theres", "are", "two", "can", "can't",
                         "somehow", "seeming", "throughout", "people", "afterwards", "away", "were", "toward",
                         "had", "best", "many", "what's", "this", "ex", "themselves", "t's",
                         "etc", "gone", "there's", "else", "th", "i've", "yours", "six", "cannot",
                         "we", "those", "definitely", "then", "inner", "said", "noone", "appreciate",
                         "former", "useful", "some", "before", "later", "per", "sorry", "rather",
                         "considering", "serious", "off", "everyone", "i'm", "thereby", "z", "you're",
                         "anyone", "hi", "truly", "uses", "whole", "knows", "it", "y",
                         "no", "gets", "appear", "not", "within", "c'mon", "nor", "co",
                         "yourself", "so", "qv", "unlikely", "meanwhile", "at", "tends", "viz",
                         "might", "whenever", "gives", "from", "his", "who", "these", "necessary",
                         "mustn't", "let", "get", "last", "sup", "way", "anyhow", "third",
                         "wouldn't", "across", "mean", "whereupon", "however", "nearly", "changes", "one",
                         "or", "self", "couldn't", "entirely", "know", "he", "followed", "described",
                         "ain't", "respectively", "l", "least", "un", "given", "eight", "behind",
                         "please", "ask", "m", "ever", "first", "she's", "nd", "well",
                         "aside", "be", "nowhere", "goes", "hereupon", "a", "lately", "latterly",
                         "something", "an", "t", "contains", "because", "sometime", "everybody", "presumably",
                         "yet", "d", "forth", "liked", "ourselves", "should", "much", "we'll",
                         "on", "greetings", "does", "thats", "became", "exactly", "nothing", "wonder",
                         "you", "sometimes", "he's", "above", "whoever", "without", "which", "her",
                         "e", "here", "lest", "overall", "u", "obviously", "apart", "unless",
                         "brief", "that", "down", "again", "have", "just", "sub", "somebody",
                         "sensible", "consider", "whose", "certain", "black", "follows", "among", "hopefully",
                         "around", "especially", "cause", "says", "several", "another", "tries", "inward",
                         "ah", "hasn't", "indicated", "their", "may", "theirs", "been", "by",
                         "already", "available", "other", "shouldn't", "zero", "thanks", "b", "taken",
                         "h", "although", "amongst", "except", "com", "sure", "otherwise", "beforehand",
                         "causes", "she", "g", "looks", "ltd", "value", "where's", "indicates",
                         "yourselves", "and", "until", "neither", "in", "more", "willing", "whether",
                         "seeing", "often", "tried", "containing", "wasn't", "appropriate", "particular", "ignored",
                         "how", "furthermore", "cannot", "beside", "about", "same", "nice", "if",
                         "brought", "ive", "aren't", "she’s", "http", "https"]

let ES_STOP_WORDS: Set = ["eres", "consigue", "hoje", "intentamos", "arriba", "tem", "j", "míos",
                         "nunca", "fostes", "ese", "tu", "éstos", "con", "estoy", "em",
                         "tanto", "mejor", "ultimo", "días", "eran", "é", "gueno", "nossas",
                         "das", "existe", "podrían", "desse", "doze", "bien", "se", "dejó",
                         "ellas", "perto", "adrede", "esos", "algmas", "siete", "possivelmente", "cuatro",
                         "quien", "mil", "haya", "faço", "maiorias", "tal", "q", "conseguir",
                         "eras", "estiveste", "tuyas", "empleas", "proximo", "que", "nenhuma", "iste",
                         "numa", "coisa", "verdade", "através", "vossa", "aqui", "estado", "pela",
                         "foi", "últimos", "temos", "ningún", "excepto", "sou", "pronto", "mal",
                         "fuimos", "ambos", "primeiro", "mayor", "ni", "eramos", "talvez", "acuerdo",
                         "las", "vamos", "dezassete", "outras", "quiza", "del", "diferentes", "usar",
                         "vosotras", "dan", "cierta", "mios", "dónde", "sé", "teu", "meus",
                         "emplean", "à", "éstas", "algo", "tres", "ele", "cosas", "ali",
                         "cento", "contra", "sigue", "todavia", "actualmente", "informo", "quedó", "pelo",
                         "porquê", "día", "ésas", "hasta", "sola", "habia", "oitavo", "afirmó",
                         "tuyo", "vosotros", "alrededor", "lejos", "fora", "nuestro", "novos", "irá",
                         "questão", "aquelas", "ésa", "trabajais", "ponto", "w", "cuánta", "quiénes",
                         "vuestros", "antano", "muchos", "esteve", "mesmo", "sido", "cual", "aquéllos",
                         "dois", "después", "poca", "temprano", "estaba", "cerca", "todavía", "van",
                         "despues", "obrigado", "cima", "p", "vai", "parece", "vens", "si",
                         "sería", "conmigo", "unos", "pocos", "tengo", "nueva", "meses", "tuya",
                         "num", "tua", "fue", "ligado", "ademas", "certeza", "vêm", "modo",
                         "han", "ningunos", "ocho", "esses", "estou", "siempre", "bastante", "trabaja",
                         "en", "conhecido", "na", "apoio", "sino", "pode", "segundo", "vos",
                         "bem", "explicó", "vós", "aquel", "cuantos", "aseguró", "manifestó", "primero",
                         "s", "dezanove", "quién", "te", "mucha", "qué", "nuevos", "puedo",
                         "fueron", "tuyos", "mismos", "nove", "teus", "aquela", "anos", "misma",
                         "nosotros", "empleais", "yo", "estão", "mí", "alguno", "trabajo", "existen",
                         "trata", "suyas", "quanto", "podrá", "i", "pocas", "usted", "dá",
                         "fim", "não", "k", "había", "pesar", "hacer", "grupo", "estar",
                         "próprio", "cuáles", "dão", "hizo", "o", "luego", "aún", "otros",
                         "bajo", "seus", "repente", "mucho", "algún", "podrian", "for", "cuántas",
                         "otra", "agregó", "algunas", "encima", "momento", "está", "sobre", "asi",
                         "buenos", "breve", "r", "v", "uso", "há", "realizó", "hecho",
                         "quando", "aquellas", "daquela", "fui", "estive", "dicen", "nos", "toda",
                         "aquella", "tendrá", "ustedes", "trabajas", "intento", "estos", "ya", "dias",
                         "ellos", "treze", "intentar", "intentas", "ninguna", "sea", "sí", "estas",
                         "suya", "aquilo", "mía", "aproximadamente", "x", "dice", "tentar", "despacio",
                         "põem", "desde", "ningunas", "podría", "algunos", "también", "sete", "decir",
                         "hicieron", "tuas", "primeira", "vindo", "hago", "mais", "três", "nuevo",
                         "tiempo", "tens", "estan", "salvo", "muy", "falta", "fazeis", "teve",
                         "f", "quizas", "gran", "última", "segunda", "tercera", "ista", "somos",
                         "sempre", "tú", "têm", "estivemos", "dijo", "sois", "soy", "quinze",
                         "ejemplo", "quero", "estivestes", "da", "donde", "cá", "otro", "quem",
                         "usas", "quiere", "todos", "quienes", "me", "ahora", "buena", "fin",
                         "deprisa", "conselho", "ou", "ampleamos", "dentro", "n", "debaixo", "dessa",
                         "arribaabajo", "sétimo", "sabe", "trabajar", "mês", "terceiro", "podria", "podrán",
                         "ante", "onde", "solo", "ése", "varias", "haceis", "as", "su",
                         "pontos", "puderam", "corrente", "um", "usan", "baixo", "mio", "buen",
                         "éste", "bom", "estava", "estes", "hoy", "esse", "muito", "según",
                         "acerca", "outra", "fazes", "alli", "obra", "seu", "este", "nuevas",
                         "últimas", "primera", "máximo", "nuestras", "saben", "sem", "peor", "pudo",
                         "incluso", "cuántos", "onze", "tenho", "los", "posição", "cuál", "podem",
                         "do", "medio", "por", "cuanto", "cuantas", "nome", "enfrente", "saber",
                         "tive", "hacerlo", "maior", "cada", "aqueles", "podriais", "podia", "al",
                         "paìs", "buenas", "ao", "isso", "mediante", "como", "es", "estará",
                         "solas", "tivemos", "nadie", "sexto", "verdadera", "nuestros", "nesse", "nossos",
                         "quieto", "tivestes", "vez", "esas", "naquela", "c", "usais", "creo",
                         "elas", "llevar", "próximo", "mias", "tipo", "local", "tenga", "quinto",
                         "fazemos", "meu", "ahí", "tener", "deben", "hablan", "intenta", "son",
                         "puede", "eu", "tudo", "era", "lá", "oitava", "estiveram", "antes",
                         "partir", "pasado", "voy", "além", "ela", "seis", "pessoas", "então",
                         "anterior", "cuenta", "novo", "menudo", "cómo", "aquélla", "daquele", "tão",
                         "vocês", "ex", "el", "pelas", "vais", "favor", "manera", "segun",
                         "siendo", "través", "ella", "oito", "cedo", "nível", "será", "sus",
                         "são", "grande", "noite", "entre", "já", "teneis", "comprido", "dio",
                         "dezoito", "total", "sim", "umas", "ainda", "nas", "allí", "haces",
                         "tempo", "ser", "adeus", "ciertas", "número", "dez", "consigo", "mías",
                         "outros", "otras", "hace", "embora", "largo", "certamente", "nova", "quer",
                         "algumas", "dado", "apenas", "sólo", "ir", "entonces", "cuánto", "hacia",
                         "fomos", "foste", "depois", "pôde", "hubo", "z", "uno", "tampoco",
                         "tienen", "neste", "vários", "quizá", "quarta", "habían", "tiene", "dúvida",
                         "duas", "vão", "muchas", "siguiente", "así", "eso", "emplear", "às",
                         "uns", "somente", "hay", "suas", "devem", "diante", "trabalho", "comentó",
                         "y", "fuera", "uma", "no", "consigues", "pais", "sabemos", "veja",
                         "llegó", "maioria", "él", "minha", "detras", "deve", "pero", "vuestra",
                         "tendes", "pasada", "você", "custa", "podemos", "pueda", "propio", "lado",
                         "ver", "encuentra", "sob", "cierto", "lleva", "após", "promeiro", "põe",
                         "ontem", "quatro", "próximos", "conseguimos", "os", "poder", "vinte", "usa",
                         "qualquer", "propios", "nada", "soyos", "aquellos", "varios", "quinta", "longe",
                         "tambien", "serán", "exemplo", "empleo", "contigo", "vem", "enseguida", "fará",
                         "fazia", "debajo", "isto", "aquele", "durante", "pouco", "forma", "debe",
                         "povo", "todas", "sei", "he", "agora", "atrás", "dia", "menor",
                         "además", "terceira", "sean", "faz", "l", "relação", "sabeis", "les",
                         "un", "lo", "estados", "parte", "informó", "aun", "tenemos", "dos",
                         "quarto", "ahi", "nuestra", "aunque", "m", "tus", "consideró", "essas",
                         "ha", "posible", "trabajamos", "realizado", "vuestras", "lugar", "sera", "a",
                         "tarde", "fazer", "t", "esto", "tentaram", "possível", "igual", "pelos",
                         "estais", "inicio", "tan", "mismas", "demás", "iniciar", "sua", "realizar",
                         "alguns", "essa", "ésos", "haber", "d", "tendrán", "una", "pues",
                         "aí", "mas", "intentais", "nem", "verdadero", "adelante", "veces", "dieron",
                         "aquél", "ter", "viagem", "habla", "conocer", "caminho", "alguna", "unas",
                         "qeu", "meio", "desta", "podrias", "de", "deverá", "verdad", "fez",
                         "casi", "área", "mia", "aquello", "poderá", "valor", "mío", "ello",
                         "sistema", "obrigada", "esa", "hacemos", "és", "e", "u", "demais",
                         "final", "enquanto", "outro", "minhas", "menos", "primeros", "general", "esta",
                         "solos", "considera", "pouca", "detrás", "catorze", "também", "último", "vezes",
                         "mencionó", "estaban", "tentei", "dezasseis", "seria", "nosotras", "mismo", "até",
                         "posso", "cuales", "hemos", "tuvo", "principalmente", "estamos", "respecto", "raras",
                         "indicó", "poco", "tiveram", "atras", "nós", "tente", "direita", "junto",
                         "tiveste", "dizem", "expresó", "vuestro", "ti", "delante", "va", "dijeron",
                         "sétima", "estuvo", "podeis", "podriamos", "propias", "dizer", "para", "verdadeiro",
                         "porque", "ano", "claro", "nessa", "dicho", "embargo", "qual", "zero",
                         "sin", "supuesto", "desligado", "b", "h", "intentan", "antaño", "ninguno",
                         "poner", "assim", "más", "consiguen", "le", "apontar", "com", "todo",
                         "ciertos", "hacen", "foram", "cuanta", "naquele", "vossos", "sabes", "trabajan",
                         "quizás", "tenido", "g", "nossa", "geral", "vaya", "aquéllas", "señaló",
                         "mientras", "usamos", "diz", "diferente", "aos", "propia", "estás", "mi",
                         "bueno", "grandes", "mis", "cuando", "eles", "pegar", "añadió", "trabalhar",
                         "queremos", "quê", "pueden", "ayer", "demasiado", "vosso", "haciendo", "sexta",
                         "nosso", "vossas", "debido", "solamente", "dar", "cinco", "ésta",
                         "tenía", "aquí", "horas", "habrá", "primer", "muitos", "tras", "deste", "moi",
                         "aussi"]


class BagGenerator {
    
    func splitIntoWords (_ text: String) -> [String] {
        var words: [String] = []
        text.enumerateSubstrings(in: text.startIndex..<text.endIndex,
                                   options: .byWords) {
                                    (substring, _, _, _) -> () in
                                    words.append(substring!.lowercased()) }
        return words
    }
    
    func isNumeric (_ string: String) -> Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
    }
        
    func bagFromText (text: String) -> [Tag] {
        let maxTags = 1
        var bag: [String: Int] = [:]
        for word in splitIntoWords(text) {
            if !EN_STOP_WORDS.contains(word) && !ES_STOP_WORDS.contains(word) && !isNumeric(word) {
                if let count = bag[word] {
                    bag[word] = count + 1
                }
                else {
                    bag[word] = 1
                }
            }
        }
        print(bag)
        var frequentWords: [Tag] = []
        var currentTags = 0
        for (word, count) in (Array(bag).sorted {$0.1 > $1.1}) {
            if count >= 4 && currentTags < maxTags && word.count > 2 {
                let newTag = Tag()
                newTag.type = .detectedObject
                newTag.id = word
                frequentWords.append(newTag)
            }
            currentTags += 1
        }
        return frequentWords
    }
    
}
